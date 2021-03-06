import 'package:flutter/material.dart';
import 'package:givit_app/core/models/givit_user.dart';
import 'package:givit_app/core/models/product.dart';
import 'package:givit_app/core/models/transport.dart';
import 'package:givit_app/core/shared/assign_card_product.dart';
import 'package:givit_app/core/shared/constant.dart';
import 'package:givit_app/services/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:ui' as ui;

class UpdateTransportPage extends StatefulWidget {
  final Size size;
  final int totalNumOfCarriers;
  final int currentNumOfCarriers;
  final String destinationAddress;
  final String pickUpAddress;
  final String notes;
  final DateTime datePickUp;
  final String transportId;
  final String carrier;
  final String carrierPhoneNumber;
  UpdateTransportPage({
    required this.size,
    required this.totalNumOfCarriers,
    required this.destinationAddress,
    required this.pickUpAddress,
    required this.notes,
    required this.datePickUp,
    required this.transportId,
    required this.carrier,
    required this.carrierPhoneNumber,
    required this.currentNumOfCarriers,
  });

  @override
  _UpdateTransportPageState createState() => _UpdateTransportPageState();
}

class _UpdateTransportPageState extends State<UpdateTransportPage> {
  void initState() {
    super.initState();
    totalNumOfCarriers = widget.totalNumOfCarriers;
    destinationAddress = widget.destinationAddress;
    pickUpAddress = widget.pickUpAddress;
    notes = widget.notes;
    datePickUp = widget.datePickUp;
    carrier = widget.carrier;
    carrierPhoneNumber = widget.carrierPhoneNumber;
  }

  final _formKey = GlobalKey<FormState>();
  String error = '';

  late int totalNumOfCarriers;
  late String destinationAddress;
  late String pickUpAddress;
  late String carrier = '';
  late String carrierPhoneNumber = '';
  late String notes;
  late DateTime datePickUp;

  @override
  Widget build(BuildContext context) {
    GivitUser user = Provider.of<GivitUser>(context);
    final DatabaseService db = DatabaseService(uid: user.uid);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
          title: Text('    ?????????? ?????????? ?????????? '),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            color: Colors.blue[100],
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextFormField(
                      initialValue: totalNumOfCarriers.toString(),
                      decoration: textInputDecoration.copyWith(
                          hintText: '???????? ??????????????'),
                      validator: (val) =>
                          val!.isEmpty ? '???????? ???????? ??????????????' : null,
                      onChanged: (val) {
                        setState(() => totalNumOfCarriers = int.parse(val));
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextFormField(
                      initialValue: destinationAddress,
                      decoration:
                          textInputDecoration.copyWith(hintText: '?????????? ??????'),
                      validator: (val) =>
                          val!.isEmpty ? '???????? ?????????? ??????' : null,
                      onChanged: (val) {
                        setState(() => destinationAddress = val);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextFormField(
                      initialValue: pickUpAddress,
                      decoration:
                          textInputDecoration.copyWith(hintText: '?????????? ??????????'),
                      validator: (val) =>
                          val!.isEmpty ? '???????? ?????????? ??????????' : null,
                      onChanged: (val) {
                        setState(() => pickUpAddress = val);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextFormField(
                      initialValue: notes,
                      decoration:
                          textInputDecoration.copyWith(hintText: '??????????'),
                      onChanged: (val) {
                        setState(() => notes = val);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextFormField(
                      initialValue: carrier,
                      decoration:
                          textInputDecoration.copyWith(hintText: '???? ????????????'),
                      onChanged: (val) {
                        setState(() => carrier = val);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextFormField(
                      initialValue: carrierPhoneNumber,
                      decoration: textInputDecoration.copyWith(
                          hintText: '???????? ?????????? ???? ????????????'),
                      onChanged: (val) {
                        setState(() => carrierPhoneNumber = val);
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: ui.TextDirection.rtl,
                    children: [
                      Text(
                        "\t:?????? ?????????? ???????? ??????????",
                        style: TextStyle(fontSize: 18),
                      ),
                      GestureDetector(
                        child: Icon(Icons.calendar_today_outlined,
                            color: Colors.black),
                        onTap: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day, 0),
                              maxTime: DateTime(
                                  DateTime.now().year + 3, 12, 31, 23, 59),
                              onChanged: (date) {}, onConfirm: (date) {
                            setState(() => datePickUp = date);
                          }, currentTime: datePickUp, locale: LocaleType.en);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: ui.TextDirection.rtl,
                    children: [
                      isDatePicked(datePickUp)
                          ? Text(
                              "?????????? ?????????? ??????????: ${datePickUp.day.toString().padLeft(2, '0')}-${datePickUp.month.toString().padLeft(2, '0')}-${datePickUp.year.toString()} ???????? ${datePickUp.hour.toString().padLeft(2, '0')}:${datePickUp.minute.toString()}",
                              style: TextStyle(fontSize: 14),
                            )
                          : Text(
                              "?????????? ?????????? ???? ????????",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    child: Text(
                      '?????????? ??????????',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (widget.currentNumOfCarriers < totalNumOfCarriers) {
                          await db.updateTransportFields(
                              'Transports', widget.transportId, {
                            'Date For Pick Up': DateFormat('yyyy-MM-dd HH:mm')
                                .format(datePickUp)
                                .toString(),
                            'Total Number Of Carriers': totalNumOfCarriers,
                            'Destination Address': destinationAddress,
                            'Pick Up Address': pickUpAddress,
                            'Status Of Transport': TransportStatus
                                .waitingForVolunteers
                                .toString()
                                .split('.')[1],
                            'Notes': notes,
                            'Carrier': carrier,
                            'Carrier Phone Number': carrierPhoneNumber,
                          });
                        } else {
                          await db.updateTransportFields(
                              'Transports', widget.transportId, {
                            'Date For Pick Up': DateFormat('yyyy-MM-dd HH:mm')
                                .format(datePickUp)
                                .toString(),
                            'Total Number Of Carriers': totalNumOfCarriers,
                            'Destination Address': destinationAddress,
                            'Pick Up Address': pickUpAddress,
                            'Status Of Transport': TransportStatus
                                .waitingForDueDate
                                .toString()
                                .split('.')[1],
                            'Notes': notes,
                            'Carrier': carrier,
                            'Carrier Phone Number': carrierPhoneNumber,
                          });
                        }
                        showDialogHelper('???????????? ???????????? ????????????', widget.size);
                        _formKey.currentState!.reset();
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDialogHelper(String dialogText, Size size) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: size.height * 0.5,
          child: AlertDialog(
            title: Text(dialogText),
            content: Stack(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("??????????"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

AssignCardProduct createDeliveryAssignFromProductSnapshot(
    Product product, Size size) {
  return AssignCardProduct(
    title: product.name,
    body: product.notes,
    schedule: '???????????? ??????????',
    type: CardType.admin,
    product: product,
    personalProducts: [],
    size: size,
    isAdmin: true,
  );
}

bool isDatePicked(DateTime datePicked) {
  return !(datePicked.year == DateTime.now().year &&
      datePicked.month == DateTime.now().month &&
      datePicked.day == DateTime.now().day &&
      datePicked.hour == DateTime.now().hour);
}
