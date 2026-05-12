import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_model.dart';

class ConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<PromoModel> getPromoBanner() {
    return _firestore
        .collection('app_config')
        .doc('promo_banner')
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return PromoModel.fromMap(doc.data()!);
          }
          // Default values if document doesn't exist yet
          return PromoModel(
            title: 'Welcome to Glow & Co.',
            subtitle: 'Discover your beauty products',
            buttonText: 'Shop Now',
            gradientHexColors: ['#FCE4EC', '#F8BBD0'],
          );
        });
  }
}
