import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sri_brijraj_web/features/add_entry/models/customer_dm.dart';
import 'package:sri_brijraj_web/features/add_entry/models/transporter_dm.dart';
import 'package:sri_brijraj_web/features/add_entry/models/vehicle_dm.dart';
import 'package:sri_brijraj_web/features/add_entry/services/add_entry_service.dart';
import 'package:sri_brijraj_web/features/history/models/history_model_dm.dart';
import 'package:sri_brijraj_web/features/web_nav/screens/web_nav_screen.dart';
import 'package:sri_brijraj_web/utils/alert_message_utils.dart';

class EditEntryController extends GetxController {
  final customerNameController = TextEditingController();
  var customers = <CustomerDm>[].obs;
  var dateController = TextEditingController();
  var filteredCustomers = <CustomerDm>[].obs;
  var filteredVehicles = <VehicleDm>[].obs;
  var fuelController = TextEditingController();
  var isFuelAdded = false.obs;
  var isLoading = false.obs;

  var items = <Map<String, dynamic>>[].obs;
  var otherItemController = TextEditingController();
  var otherItemQtyController = TextEditingController();
  var selectedCustomerCode = ''.obs;
  var selectedCustomerName = ''.obs;
  var selectedFuelType = 'Diesel'.obs;
  var selectedVehicleCode = 0.obs;
  var selectedVehicleNo = ''.obs;
  final vehicleNoController = TextEditingController();
  var vehicles = <VehicleDm>[].obs;
  final transporterNameController = TextEditingController();
  var transporters = <TransporterDm>[].obs;
  var filteredTransporters = <TransporterDm>[].obs;
  var selectedTransporter = ''.obs;
  final remarkController = TextEditingController();

  var editSlipNo = ''.obs;

  // ── Typing flags: dropdown shows ONLY when user is actively typing ──────
  var isUserTypingCustomer = false.obs;
  var isUserTypingTransporter = false.obs;
  var isUserTypingVehicle = false.obs;

  final formKey = GlobalKey<FormState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void setFuelType(String type) => selectedFuelType.value = type;

  void addItem({required String iName, required double qty}) {
    items.add({"INAME": iName, "QTY": qty});
    if (iName == 'Petrol' || iName == 'Diesel') isFuelAdded.value = true;
  }

  void removeItem(int index) {
    final removedItem = items.removeAt(index);
    if (removedItem['INAME'] == 'Petrol' || removedItem['INAME'] == 'Diesel') {
      isFuelAdded.value = items.any(
        (item) => item['INAME'] == 'Petrol' || item['INAME'] == 'Diesel',
      );
    }
  }

  Future<void> fetchCustomers({String? pname}) async {
    try {
      isLoading.value = true;
      final fetchedCustomers = await AddEntryService.fetchCustomersByName(pname);
      customers.assignAll(fetchedCustomers);
      if (pname == null || pname.isEmpty) {
        filteredCustomers.assignAll(customers);
      } else {
        filterCustomers(pname);
      }
    } catch (e) {
      showErrorDialog('Failed to load customers', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers.assignAll(customers);
    } else {
      filteredCustomers.value = customers
          .where((c) => c.pname.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void setSelectedCustomer(CustomerDm customer) {
    // User selected from dropdown — stop treating this as a "typing" session
    isUserTypingCustomer.value = false;
    selectedCustomerName.value = customer.pname;
    selectedCustomerCode.value = customer.pcode;
    customerNameController.text = customer.pname;
    filteredCustomers.clear();
    filterVehiclesByCustomer(customer.pcode);
  }

  void handleNewCustomer(String customerName) {
    // User is actively typing — show dropdown
    isUserTypingCustomer.value = true;
    selectedCustomerName.value = customerName;
    selectedCustomerCode.value = '';
    final existing = customers.firstWhere(
      (c) => c.pname.toLowerCase() == customerName.toLowerCase(),
      orElse: () => CustomerDm(pname: '', pcode: ''),
    );
    if (existing.pcode.isNotEmpty) {
      selectedCustomerCode.value = existing.pcode;
      filterVehiclesByCustomer(existing.pcode);
    } else {
      filteredVehicles.clear();
    }
  }

  Future<void> fetchTransporters({String? tname}) async {
    try {
      isLoading.value = true;
      final fetched = await AddEntryService.fetchTransporter(tname);
      transporters.assignAll(fetched);
      if (tname == null || tname.isEmpty) {
        filteredTransporters.assignAll(transporters);
      } else {
        filterTransporters(tname);
      }
    } catch (e) {
      showErrorDialog('Failed to load transporters', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterTransporters(String query) {
    if (query.isEmpty) {
      filteredTransporters.assignAll(transporters);
    } else {
      filteredTransporters.value = transporters
          .where((t) =>
              t.transporterName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void setSelectedTransporter(TransporterDm transporter) {
    // User selected from dropdown — stop treating this as a "typing" session
    isUserTypingTransporter.value = false;
    selectedTransporter.value = transporter.transporterName;
    transporterNameController.text = transporter.transporterName;
    filteredTransporters.clear();
  }

  void handleNewTransporter(String transporterName) {
    // User is actively typing — show dropdown
    isUserTypingTransporter.value = true;
    selectedTransporter.value = transporterName;
  }

  Future<void> fetchVehicles({String? vehicleNo}) async {
    try {
      isLoading.value = true;
      final fetched = await AddEntryService.fetchVehicle(vehicleNo);
      vehicles.assignAll(fetched);
      if (vehicleNo == null || vehicleNo.isEmpty) {
        filteredVehicles.assignAll(vehicles);
      } else {
        filterVehicles(vehicleNo);
      }
    } catch (e) {
      showErrorDialog('Failed to load vehicles', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterVehicles(String query) {
    if (query.isEmpty) {
      filteredVehicles.assignAll(vehicles);
    } else {
      filteredVehicles.value = vehicles
          .where((v) =>
              v.vehicleNo.toLowerCase().contains(query.toLowerCase()) &&
              (selectedCustomerCode.value.isEmpty ||
                  v.pCode == selectedCustomerCode.value))
          .toList();
    }
  }

  void filterVehiclesByCustomer(String pCode) {
    filteredVehicles.value =
        vehicles.where((v) => v.pCode == pCode).toList();
  }

  void setSelectedVehicle(VehicleDm vehicle) {
    // User selected from dropdown — stop treating this as a "typing" session
    isUserTypingVehicle.value = false;
    selectedVehicleNo.value = vehicle.vehicleNo;
    selectedVehicleCode.value = vehicle.vehicleCode;
    vehicleNoController.text = vehicle.vehicleNo;
    final customer = customers.firstWhere(
      (c) => c.pcode == vehicle.pCode,
      orElse: () => CustomerDm(pname: '', pcode: ''),
    );
    if (customer.pcode.isNotEmpty) {
      selectedCustomerName.value = customer.pname;
      selectedCustomerCode.value = customer.pcode;
      customerNameController.text = customer.pname;
    }
    filteredVehicles.clear();
  }

  void handleNewVehicle(String vehicleNo) {
    // User is actively typing — show dropdown
    isUserTypingVehicle.value = true;
    selectedVehicleNo.value = vehicleNo;
    selectedVehicleCode.value = 0;
    final existing = vehicles.firstWhere(
      (v) => v.vehicleNo.toLowerCase() == vehicleNo.toLowerCase(),
      orElse: () => VehicleDm(vehicleNo: '', vehicleCode: 0, pCode: ''),
    );
    if (existing.vehicleCode != 0) {
      selectedVehicleCode.value = existing.vehicleCode;
    }
  }

  /// Populate all fields from a [HistoryModelDm] for editing.
void autofillEdit(HistoryModelDm history) {
  editSlipNo.value = history.slipNo;
  items.clear();
  isFuelAdded.value = false;

  try {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd-MMM-yyyy').parse(history.date);
    } catch (_) {
      parsedDate = DateFormat('dd-MM-yyyy').parse(history.date);
    }
    dateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (_) {
    dateController.text = history.date;
  }

  transporterNameController.text = history.transporter;
  customerNameController.text = history.pname ?? '';
  vehicleNoController.text = history.vehicleNo;
  remarkController.text = history.remark;

  selectedCustomerName.value = history.pname ?? '';
  selectedTransporter.value = history.transporter;
  selectedVehicleNo.value = history.vehicleNo;

  // ── Resolve PCODE from loaded customers ──────────────────────────────
  final matchedCustomer = customers.firstWhere(
    (c) => c.pname.toLowerCase() == (history.pname ?? '').toLowerCase(),
    orElse: () => CustomerDm(pname: '', pcode: ''),
  );
  if (matchedCustomer.pcode.isNotEmpty) {
    selectedCustomerCode.value = matchedCustomer.pcode;

    // ── Resolve VehicleCode from loaded vehicles ──────────────────────
    final matchedVehicle = vehicles.firstWhere(
      (v) =>
          v.vehicleNo.toLowerCase() == history.vehicleNo.toLowerCase() &&
          v.pCode == matchedCustomer.pcode,
      orElse: () => VehicleDm(vehicleNo: '', vehicleCode: 0, pCode: ''),
    );
    if (matchedVehicle.vehicleCode != 0) {
      selectedVehicleCode.value = matchedVehicle.vehicleCode;
    }
  }

  for (final item in history.items) {
    addItem(iName: item.iname, qty: double.tryParse(item.qty) ?? 0.0);
  }

  isUserTypingCustomer.value = false;
  isUserTypingTransporter.value = false;
  isUserTypingVehicle.value = false;
}

  Future<void> updateEntry() async {
    final userId = int.parse((await secureStorage.read(key: 'userId'))!);
    try {
      isLoading.value = true;
      final message = await AddEntryService.addEntry(
        slipNo: editSlipNo.value,
        date: DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd-MM-yyyy').parse(dateController.text)),
        transporter: transporterNameController.text,
        pname: selectedCustomerName.value,
        pcode: selectedCustomerCode.value,
        vehicleNo: selectedVehicleNo.value,
        vehicleCode: selectedVehicleCode.value == 0
            ? ''
            : selectedVehicleCode.value.toString(),
        remark: remarkController.text,
        userId: userId,
        items: items,
      );
      showSuccessDialog('Updated', message);
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(() => WebNavScreen());
    } catch (e) {
      showErrorDialog('Failed to update', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}