import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:givit_app/core/models/givit_user.dart';
import 'package:givit_app/core/models/product.dart';
import 'package:givit_app/core/models/transport.dart';
import 'package:givit_app/core/shared/constant.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final CollectionReference givitUsersCollection =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('Products');
  final CollectionReference transportsCollection =
      FirebaseFirestore.instance.collection('Transports');
  final CollectionReference communityTransportsCollection =
      FirebaseFirestore.instance.collection('Community Transports');
  final CollectionReference storageTransportsCollection =
      FirebaseFirestore.instance.collection('Storage Transports');
  final CollectionReference storageProductsCollection =
      FirebaseFirestore.instance.collection('Storage Products');

  final Map<String, CollectionReference> collectionMap = {
    'Users': FirebaseFirestore.instance.collection('Users'),
    'Products': FirebaseFirestore.instance.collection('Products'),
    'Transports': FirebaseFirestore.instance.collection('Transports'),
    'Community Transports':
        FirebaseFirestore.instance.collection('Community Transports'),
    'Storage Transports':
        FirebaseFirestore.instance.collection('Storage Transports'),
    'Storage Products':
        FirebaseFirestore.instance.collection('Storage Products'),
  };

  Future<String> moveProductCollection(Product product, String transportId,
      String fromCollection, String toCollection) async {
    await collectionMap[fromCollection]!.doc(product.id).delete();
    return await collectionMap[toCollection]!
        .add({
          'Notes': product.notes,
          'Product Name': product.name,
          'State Of Product': product.state.toString().split('.')[1],
          "Owner's Name": product.ownerName,
          "Owner's Phone Number": product.ownerPhoneNumber,
          'Time Span For Pick Up': product.timeForPickUp,
          'Pick Up Address': product.pickUpAddress,
          'Product Picture URL': product.productPictureURL,
          'Assigned Transport ID': transportId,
          'Weight': product.weight,
          'Length': product.length,
          'Width': product.width,
          'Status Of Product': ProductStatus.delivered.toString().split('.')[1],
        })
        .then((value) => value.id)
        .catchError((error) {
          print(error);
        });
  }

  Future<String> moveTransportCollection(Transport transport, String sumUp,
      String fromCollection, String toCollection) async {
    await collectionMap[fromCollection]!.doc(transport.id).delete();
    return await collectionMap[toCollection]!.add({
      'Current Number Of Carriers': transport.currentNumOfCarriers,
      'Total Number Of Carriers': transport.totalNumOfCarriers,
      'Destination Address': transport.destinationAddress,
      'Pick Up Address': transport.pickUpAddress,
      'Date For Pick Up': transport.datePickUp.toString(),
      'Products': [],
      'Carriers': transport.carriers,
      'Carriers Phone Numbers': transport.carriersPhoneNumbers,
      'Status Of Transport':
          TransportStatus.carriedOut.toString().split('.')[1],
      'Pictures': [],
      'Notes': transport.notes,
      'SumUp': sumUp,
    }).then((value) => value.id);
  }

  Future<void> addGivitUser(String email, String fullName, String password,
      String phoneNumber) async {
    return await givitUsersCollection.doc(uid).set({
      'Email': email,
      'Full Name': fullName,
      'Password': password,
      'Phone Number': phoneNumber,
      'Profile Picture URL': defaultProfileUrl,
      'Products': [],
      'Transports': [],
      'Role': 'User',
    });
  }

  Future<void> updateAssignProducts(
      List<String> products, Map<String, Object?> data) async {
    Set mySet = products.toSet();
    await productsCollection.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((product) {
            if (mySet.contains(product.id)) {
              updateProductFields(product.id, data);
            }
          })
        });
  }

  Future<void> updateAssignGivitUsers(
      List<String> givitUsers, Map<String, Object?> data) async {
    Set mySet = givitUsers.toSet();
    await givitUsersCollection.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((givitUser) {
            if (mySet.contains(givitUser.id)) {
              updateGivitUserFieldsById(givitUser.id, data);
            }
          })
        });
  }

  Future<Transport> getTransportByID(String id) async {
    return await transportsCollection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Object?> document) {
      var snapshotData = document.data() as Map;
      return Transport.transportFromDocument(snapshotData, document.id);
    });
  }

  Future<Product> getProductByID(String id) async {
    return await productsCollection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Object?> document) {
      var snapshotData = document.data() as Map;
      return Product.productFromDocument(snapshotData, document.id);
    });
  }

  Future<GivitUser> getUserByID(String? id) async {
    return await givitUsersCollection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Object?> document) {
      return GivitUser.fromFirestorUser(document);
    });
  }

  Future<void> updateGivitUserFields(Map<String, Object?> data) async {
    return await givitUsersCollection.doc(uid).update(data);
  }

  Future<void> updateGivitUserFieldsById(
      String id, Map<String, Object?> data) async {
    return await givitUsersCollection.doc(id).update(data);
  }

  Future<void> updateProductFields(String id, Map<String, Object?> data) async {
    return await productsCollection.doc(id).update(data);
  }

  Future<void> updateTransportFields(
      String transportCollection, String id, Map<String, Object?> data) async {
    return await collectionMap[transportCollection]!.doc(id).update(data);
  }

  Future<String> addTransport({
    int? totalNumOfCarriers,
    String? destinationAddress,
    String? pickUpAddress,
    String? notes,
    List<String>? products,
    DateTime? datePickUp,
  }) async {
    return await transportsCollection.add({
      'Current Number Of Carriers': 0,
      'Total Number Of Carriers': totalNumOfCarriers ?? 0,
      'Destination Address': destinationAddress ?? '',
      'Pick Up Address': pickUpAddress ?? '',
      'Date For Pick Up':
          DateFormat('yyyy-MM-dd hh:mm').format(datePickUp!).toString(),
      'Products': products ?? [],
      'Carriers': [],
      'Carriers Phone Numbers': [],
      'Status Of Transport':
          TransportStatus.waitingForVolunteers.toString().split('.')[1],
      'Pictures': [],
      'Notes': notes ?? '',
      'SumUp': '',
    }).then((value) => value.id);
  }

  Stream<QuerySnapshot<Object?>> get transportsData {
    return transportsCollection.snapshots();
  }

  Future<String> addProduct(
      {String? name,
      String? notes,
      String? productState,
      String? ownerName,
      int? ownerPhoneNumber,
      String? timePickUp,
      String? pickUpAddress,
      String? productPictureUrl,
      String? assignTransportId,
      int? weight,
      int? length,
      int? width,
      String? productStatus}) async {
    Reference ref =
        FirebaseStorage.instance.ref().child("/default_furniture_pic.jpeg");
    String? url = productPictureUrl == ''
        ? (await ref.getDownloadURL()).toString()
        : productPictureUrl;
    return await productsCollection.add({
      'Notes': notes,
      'Product Name': name,
      'State Of Product': productState,
      "Owner's Name": ownerName,
      "Owner's Phone Number": ownerPhoneNumber,
      'Time Span For Pick Up': timePickUp,
      'Pick Up Address': pickUpAddress,
      'Product Picture URL': url,
      'Assigned Transport ID': assignTransportId,
      'Weight': weight,
      'Length': length,
      'Width': width,
      'Status Of Product': productStatus,
    }).then((value) => value.id);
  }

  Future<void> deleteProductFromGivitUserList(String productId) async {
    return await givitUsersCollection
        .get()
        .then((QuerySnapshot<Object?> querySnapshot) => {
              querySnapshot.docs.forEach((document) {
                GivitUser givitUser = GivitUser.fromFirestorUser(document);
                if (givitUser.products.contains(productId)) {
                  updateGivitUserFieldsById(givitUser.uid, {
                    "Products": FieldValue.arrayRemove(['$productId'])
                  });
                }
              })
            });
  }

  Future<void> deleteTransportFromGivitUserList(String transportId) async {
    return await givitUsersCollection
        .get()
        .then((QuerySnapshot<Object?> querySnapshot) => {
              querySnapshot.docs.forEach((document) {
                GivitUser givitUser = GivitUser.fromFirestorUser(document);
                if (givitUser.transports.contains(transportId)) {
                  updateGivitUserFieldsById(givitUser.uid, {
                    "Transports": FieldValue.arrayRemove(['$transportId'])
                  });
                }
              })
            });
  }

  Future<void> deleteProductFromTransportList(
      String productId, String transportId) async {
    await transportsCollection.doc(transportId).update({
      "Carriers": FieldValue.arrayRemove(['$productId'])
    });
  }

  Future<void> deleteProductFromProductList(String id) async {
    return await productsCollection.doc(id).delete();
  }

  Future<void> deleteTransportFromTransportList(String id) async {
    return await transportsCollection.doc(id).delete();
  }

  Stream<QuerySnapshot<Object?>> get producstData {
    return productsCollection.snapshots();
  }

  GivitUser _givitUserDataFromSnapshot(DocumentSnapshot snapshot) {
    var snapshotData = snapshot.data() as Map;
    return GivitUser(
      uid: uid,
      email: snapshotData['Email'],
      password: snapshotData['Password'],
      fullName: snapshotData['Full Name'],
      phoneNumber: snapshotData['Phone Number'],
      profilePictureURL: snapshotData['Profile Picture URL'],
      role: snapshotData['Role'],
      products: List.from(snapshotData['Products']),
      transports: List.from(snapshotData['Transports']),
    );
  }

  Stream<GivitUser> get givitUserData {
    return givitUsersCollection
        .doc(uid)
        .snapshots()
        .map(_givitUserDataFromSnapshot);
  }

  Stream<QuerySnapshot<Object?>> get givitUsersData {
    return givitUsersCollection.snapshots();
  }
}
