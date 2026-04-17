import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sri_brijraj_web/constants/color_constants.dart';
import 'package:sri_brijraj_web/constants/image_constants.dart';
import 'package:sri_brijraj_web/features/add_entry/controllers/edit_entry_controller.dart';
import 'package:sri_brijraj_web/features/history/models/history_model_dm.dart';
import 'package:sri_brijraj_web/styles/textstyles.dart';
import 'package:sri_brijraj_web/utils/alert_message_utils.dart';
import 'package:sri_brijraj_web/utils/text_input_formatters.dart';
import 'package:sri_brijraj_web/widgets/app_button.dart';
import 'package:sri_brijraj_web/widgets/app_date_picker_text_form_field.dart';
import 'package:sri_brijraj_web/widgets/app_loading_overlay.dart';
import 'package:sri_brijraj_web/widgets/app_paddings.dart';
import 'package:sri_brijraj_web/widgets/app_secondary_button.dart';
import 'package:sri_brijraj_web/widgets/app_size_extensions.dart';
import 'package:sri_brijraj_web/widgets/app_spacings.dart';
import 'package:sri_brijraj_web/widgets/app_text_form_field.dart';

class EditEntryScreen extends StatefulWidget {
  /// The history record to edit. Passed via constructor or Get.arguments.
  final HistoryModelDm history;

  const EditEntryScreen({
    super.key,
    required this.history,
  });

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  // late final EditEntryController _controller;
   final EditEntryController _controller = Get.put(
    EditEntryController(),
  );

  @override
  void initState() {
    super.initState();
    _controller.fetchCustomers();
    _controller.autofillEdit(widget.history);
    _initAndAutofill();
  }

  @override
  void dispose() {
    Get.delete<EditEntryController>(tag: widget.history.slipNo);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _controller.filteredCustomers.clear();
            _controller.filteredVehicles.clear();
            _controller.filteredTransporters.clear();
            // Reset typing flags when tapping outside
            _controller.isUserTypingCustomer.value = false;
            _controller.isUserTypingTransporter.value = false;
            _controller.isUserTypingVehicle.value = false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: kColorwhite,
            body: Center(
              child: Padding(
                padding: AppPaddings.p20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _controller.formKey,
                          child: Column(
                            children: [
                              // ── Date ────────────────────────────────────
                              SizedBox(
                                width: 0.4.screenWidth,
                                child: AppDatePickerTextFormField(
                                  dateController: _controller.dateController,
                                  hintText: 'Date',
                                ),
                              ),
                              AppSpaces.v20,

                              // ── Transporter ─────────────────────────────
                              SizedBox(
                                width: 0.4.screenWidth,
                                child: AppTextFormField(
                                  controller:
                                      _controller.transporterNameController,
                                  hintText: 'Transporter',
                                  onChanged: (value) {
                                    _controller.fetchTransporters(tname: value);
                                    _controller.handleNewTransporter(value);
                                  },
                                  inputFormatters: [
                                    TitleCaseTextInputFormatter(),
                                  ],
                                ),
                              ),
                              Obx(() {
                                // Show dropdown only when user is actively typing
                                if (!_controller.isUserTypingTransporter.value ||
                                    _controller.filteredTransporters.isEmpty ||
                                    _controller.transporterNameController.text
                                        .isEmpty) {
                                  return const SizedBox();
                                }
                                return _dropdownContainer(
                                  width: 0.4.screenWidth,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        _controller.filteredTransporters.length,
                                    itemBuilder: (context, index) {
                                      final transporter =
                                          _controller.filteredTransporters[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _controller.setSelectedTransporter(
                                              transporter);
                                          _controller.filteredTransporters
                                              .clear();
                                        },
                                        child: _dropdownItemText(
                                            transporter.transporterName),
                                      );
                                    },
                                  ),
                                );
                              }),
                              AppSpaces.v20,

                              // ── Owner / Customer ─────────────────────────
                              SizedBox(
                                width: 0.4.screenWidth,
                                child: AppTextFormField(
                                  controller:
                                      _controller.customerNameController,
                                  hintText: 'Owner',
                                  onChanged: (value) {
                                    _controller.fetchCustomers(pname: value);
                                    _controller.handleNewCustomer(value);
                                  },
                                  inputFormatters: [
                                    TitleCaseTextInputFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter owner name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Obx(() {
                                // Show dropdown only when user is actively typing
                                if (!_controller.isUserTypingCustomer.value ||
                                    _controller.filteredCustomers.isEmpty ||
                                    _controller
                                        .customerNameController.text.isEmpty) {
                                  return const SizedBox();
                                }
                                return _dropdownContainer(
                                  width: 0.4.screenWidth,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        _controller.filteredCustomers.length,
                                    itemBuilder: (context, index) {
                                      final customer =
                                          _controller.filteredCustomers[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _controller
                                              .setSelectedCustomer(customer);
                                          _controller.filteredCustomers.clear();
                                        },
                                        child:
                                            _dropdownItemText(customer.pname),
                                      );
                                    },
                                  ),
                                );
                              }),
                              AppSpaces.v20,

                              // ── Vehicle ──────────────────────────────────
                              SizedBox(
                                width: 0.4.screenWidth,
                                child: AppTextFormField(
                                  controller: _controller.vehicleNoController,
                                  hintText: 'Vehicle',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a vehicle no';
                                    }
                                    return null;
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                    UpperCaseTextInputFormatter(),
                                  ],
                                  onChanged: (value) {
                                    if (_controller
                                        .selectedCustomerCode.value.isNotEmpty) {
                                      _controller.fetchVehicles(vehicleNo: value);
                                    } else {
                                      _controller.filteredVehicles.clear();
                                    }
                                    _controller.handleNewVehicle(value);
                                  },
                                ),
                              ),
                              Obx(() {
                                // Show dropdown only when user is actively typing
                                if (!_controller.isUserTypingVehicle.value ||
                                    _controller.filteredVehicles.isEmpty ||
                                    _controller.vehicleNoController.text.isEmpty) {
                                  return const SizedBox();
                                }
                                return _dropdownContainer(
                                  width: 0.4.screenWidth,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        _controller.filteredVehicles.length,
                                    itemBuilder: (context, index) {
                                      final vehicle =
                                          _controller.filteredVehicles[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _controller.setSelectedVehicle(vehicle);
                                          _controller.filteredVehicles.clear();
                                        },
                                        child: _dropdownItemText(
                                            vehicle.vehicleNo),
                                      );
                                    },
                                  ),
                                );
                              }),
                              AppSpaces.v20,

                              // ── Remark ───────────────────────────────────
                              SizedBox(
                                width: 0.4.screenWidth,
                                child: AppTextFormField(
                                  controller: _controller.remarkController,
                                  hintText: 'Remark',
                                ),
                              ),
                              AppSpaces.v20,

                              // ── Fuel & Other buttons ──────────────────────
                              SizedBox(
                                width: 0.4.screenWidth,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Fuel button
                                    Obx(() => AppSecondaryButton(
                                          onPressed:
                                              _controller.isFuelAdded.value
                                                  ? () {}
                                                  : () => _showFuelDialog(
                                                      context),
                                          buttonWidth: 0.175.screenWidth,
                                          buttonColor:
                                              _controller.isFuelAdded.value
                                                  ? kColorLightGrey
                                                  : kColorPrimary,
                                          title: 'Fuel',
                                          titleSize: FontSize.k20FontSize,
                                          icon: kIconFuel,
                                          buttonHeight: 60,
                                        )),

                                    // Other button
                                    AppSecondaryButton(
                                      onPressed: () =>
                                          _showOtherDialog(context),
                                      buttonWidth: 0.175.screenWidth,
                                      buttonColor: kColorPrimary,
                                      title: 'Other',
                                      titleSize: FontSize.k20FontSize,
                                      icon: kIconOther,
                                      buttonHeight: 60,
                                    ),
                                  ],
                                ),
                              ),
                              AppSpaces.v20,

                              // ── Items list ────────────────────────────────
                              Obx(() => SizedBox(
                                    width: 0.4.screenWidth,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _controller.items.length,
                                      itemBuilder: (context, index) {
                                        final item =
                                            _controller.items[index];
                                        return Column(
                                          children: [
                                            Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                side: BorderSide(
                                                    color: kColorBlack),
                                              ),
                                              color: kColorwhite,
                                              child: ListTile(
                                                title: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 0.25.screenWidth,
                                                      child: Text(
                                                        item['INAME'],
                                                        style: TextStyles
                                                            .kSemiBoldInstrumentSans(
                                                                color:
                                                                    kColorPrimary)
                                                            .copyWith(
                                                                height: 1),
                                                      ),
                                                    ),
                                                    AppSpaces.h10,
                                                    SizedBox(
                                                      width: 0.07.screenWidth,
                                                      child: Text(
                                                        item['INAME'] ==
                                                                    'Petrol' ||
                                                                item['INAME'] ==
                                                                    'Diesel'
                                                            ? '${item['QTY']}  Litre'
                                                            : item['QTY']
                                                                .toString(),
                                                        style: TextStyles
                                                            .kSemiBoldInstrumentSans(
                                                                color:
                                                                    kColorPrimary)
                                                            .copyWith(
                                                                height: 1),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      _controller
                                                          .removeItem(index),
                                                ),
                                              ),
                                            ),
                                            AppSpaces.v6,
                                          ],
                                        );
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Update button ─────────────────────────────────────
                    AppSpaces.v20,
                    AppButton(
                      onPressed: () {
                        if (_controller.formKey.currentState!.validate()) {
                          if (_controller.items.isEmpty) {
                            showErrorDialog(
                                'Oops!', 'Please enter an item to continue');
                          } else {
                            _controller.updateEntry();
                          }
                        }
                      },
                      buttonWidth: 0.4.screenWidth,
                      title: 'Update',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Loading overlay ───────────────────────────────────────────────
        Obx(() => CustomLoadingOverlay(
              isLoading: _controller.isLoading.value,
            )),
      ],
    );
  }

  
Future<void> _initAndAutofill() async {
  await Future.wait([
    _controller.fetchCustomers(),
    _controller.fetchVehicles(),
  ]);
  _controller.autofillEdit(widget.history);
}


  // ── Private helper widgets ──────────────────────────────────────────────

  Widget _dropdownContainer({required double width, required Widget child}) {
    return Container(
      height: 0.3.screenHeight,
      width: width,
      decoration: BoxDecoration(
        color: kColorwhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kColorBlack),
      ),
      padding: AppPaddings.p12,
      child: child,
    );
  }

  Widget _dropdownItemText(String text) {
    return Text(
      text,
      style: TextStyles.kSemiBoldInstrumentSans(color: kColorPrimary)
          .copyWith(height: 2),
    );
  }

  void _showFuelDialog(BuildContext context) {
    _controller.setFuelType('Diesel');
    _controller.fuelController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: kColorwhite,
        surfaceTintColor: kColorwhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: AppPaddings.p20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 0.4.screenWidth,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      kIconFuel,
                      colorFilter: const ColorFilter.mode(
                          kColorPrimary, BlendMode.srcIn),
                    ),
                    AppSpaces.h20,
                    Text(
                      'Fuel',
                      style: TextStyles.kBoldInstrumentSans(
                          color: kColorPrimary, fontSize: 24),
                    ),
                  ],
                ),
              ),
              AppSpaces.v20,
              SizedBox(
                width: 0.4.screenWidth,
                child: AppTextFormField(
                  controller: _controller.fuelController,
                  hintText: 'Litre',
                  keyboardType: TextInputType.number,
                ),
              ),
              AppSpaces.v20,
              Obx(() => SizedBox(
                    width: 0.4.screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fuelTypeRadio('Petrol'),
                        _fuelTypeRadio('Diesel'),
                      ],
                    ),
                  )),
              AppSpaces.v20,
              AppSecondaryButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final qty =
                      double.tryParse(_controller.fuelController.text) ?? 0.0;
                  if (qty > 0) {
                    _controller.addItem(
                        iName: _controller.selectedFuelType.value, qty: qty);
                    Get.back();
                  }
                },
                buttonWidth: 0.4.screenWidth,
                buttonHeight: 60,
                title: 'Add',
                icon: kIconFuel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fuelTypeRadio(String type) {
    return GestureDetector(
      onTap: () => _controller.setFuelType(type),
      child: Row(
        children: [
          Radio<String>(
            activeColor: kColorPrimary,
            value: type,
            groupValue: _controller.selectedFuelType.value,
            onChanged: (value) {
              if (value != null) _controller.setFuelType(value);
            },
          ),
          Text(
            type,
            style:
                TextStyles.kSemiBoldInstrumentSans(color: kColorPrimary),
          ),
        ],
      ),
    );
  }

  void _showOtherDialog(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.otherItemController.clear();
    _controller.otherItemQtyController.clear();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: kColorwhite,
        surfaceTintColor: kColorwhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: AppPaddings.p20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 0.4.screenWidth,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      kIconOther,
                      colorFilter: const ColorFilter.mode(
                          kColorPrimary, BlendMode.srcIn),
                    ),
                    AppSpaces.h20,
                    Text(
                      'Other',
                      style: TextStyles.kBoldInstrumentSans(
                          color: kColorPrimary, fontSize: 24),
                    ),
                  ],
                ),
              ),
              AppSpaces.v20,
              SizedBox(
                width: 0.4.screenWidth,
                child: AppTextFormField(
                  controller: _controller.otherItemController,
                  hintText: 'Item',
                  inputFormatters: [TitleCaseTextInputFormatter()],
                ),
              ),
              AppSpaces.v20,
              SizedBox(
                width: 0.4.screenWidth,
                child: AppTextFormField(
                  controller: _controller.otherItemQtyController,
                  hintText: 'Qty',
                  keyboardType: TextInputType.number,
                ),
              ),
              AppSpaces.v20,
              AppSecondaryButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final qty = double.tryParse(
                          _controller.otherItemQtyController.text) ??
                      0.0;
                  if (qty > 0) {
                    _controller.addItem(
                        iName: _controller.otherItemController.text, qty: qty);
                    Get.back();
                  }
                },
                buttonHeight: 60,
                buttonWidth: 0.4.screenWidth,
                title: 'Add',
                icon: kIconOther,
              ),
            ],
          ),
        ),
      ),
    );
  }
}