import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase{
  static String url='mongodb+srv://chirayu:chirayu1289@recipeusers.bnjl8.mongodb.net/?retryWrites=true&w=majority&appName=recipeusers';
  static const String COLLECTION_NAME = "saved-recipes";

  static late Db db;
  static late DbCollection collection;

  static connect() async{
    db = await Db.create(url);
    await db.open();
    collection = db.collection(COLLECTION_NAME);
    print("Connected to MongoDB Database!");
  }
}