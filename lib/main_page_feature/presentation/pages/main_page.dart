import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:givit_app/core/models/givit_user.dart';
import 'package:givit_app/core/models/product.dart';
import 'package:givit_app/core/models/transport.dart';
import 'package:givit_app/core/shared/loading.dart';
import 'package:givit_app/core/shared/assign_card.dart';
import 'package:givit_app/services/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final Size size;
  MainPage({required this.size});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    GivitUser user = Provider.of<GivitUser>(context);
    final DatabaseService db = DatabaseService(uid: user.uid);
    return StreamBuilder<QuerySnapshot>(
        stream: db.producstData,
        builder: (context, snapshotProduct) {
          if (snapshotProduct.hasError) {
            return Text('Something went wrong');
          }

          if (snapshotProduct.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          return StreamBuilder<QuerySnapshot>(
              stream: db.transportsData,
              builder: (context, snapshotTransport) {
                if (snapshotTransport.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshotTransport.connectionState ==
                    ConnectionState.waiting) {
                  return Loading();
                }

                return Container(
                  color: Colors.blue[100],
                  height: 400.0,
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        snapshotProduct.data!.docs
                            .map((DocumentSnapshot document) {
                          var snapshotData = document.data() as Map;
                          Product product = Product.productFromDocument(
                              snapshotData, document.id);
                          return createDeliveryAssignFromProductSnapshot(
                              product, widget.size);
                        }).toList(),
                        snapshotTransport.data!.docs
                            .map((DocumentSnapshot document) {
                          var snapshotData = document.data() as Map;
                          Transport transport = Transport.transportFromDocument(
                              snapshotData, document.id);
                          return createDeliveryAssignFromTransportSnapshot(
                              transport, widget.size);
                        }).toList(),
                      ].expand((element) => element).toList(),
                    ),
                  ),
                );
              });
        });
  }
}

DeliveryAssign createDeliveryAssignFromProductSnapshot(
    Product product, Size size) {
  return DeliveryAssign(
    title: product.name,
    body: product.notes,
    schedule: 'לשיבוץ חיפוש',
    isProduct: true,
    isMain: true,
    id: product.id,
    products: [],
    size: size,
  );
}

DeliveryAssign createDeliveryAssignFromTransportSnapshot(
    Transport transport, Size size) {
  String date;
  if (transport.datePickUp != null) {
    date =
        DateFormat('yyyy-MM-dd hh:mm').format(transport.datePickUp).toString();
  } else {
    date = '';
  }
  return DeliveryAssign(
    title: date + ' :הובלה ב',
    body: transport.notes,
    schedule: 'לשיבוץ הובלה',
    isProduct: false,
    isMain: true,
    id: transport.id,
    products: [],
    size: size,
  );
}
