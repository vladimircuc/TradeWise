import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/profit_at_time.dart';
import '../models/profit_helper.dart';
import '../models/stock_model.dart';
import '../models/transaction_model.dart';

class DataBase_Controller {
  DataBase_Controller();
  List<Stock> favStocks = [];
  List<Trans> trans = [];

  Future<double> getUserBalance(String customUserId) async {
    //retreives the balance of a user from the database
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot =
          await users.where('userId', isEqualTo: customUserId).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userDocument = userQuerySnapshot.docs.first;
        double balance = userDocument.get('balance');
        return balance;
      } else {
        print("No user with the id");
        return 0;
      }
    } catch (error) {
      print("Failed to retrieve user balance: $error");
      return 0;
    }
  }

  Future<double> getAllTimeProfit(String customUserId) async {
    //retrieves all time profit from the databas of a user
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot =
          await users.where('userId', isEqualTo: customUserId).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userDocument = userQuerySnapshot.docs.first;
        double profit = userDocument.get('totalProfit');
        return profit;
      } else {
        print("No user with the id");
        return 0;
      }
    } catch (error) {
      print("Failed to retrieve user balance: $error");
      return 0;
    }
  }

  Future<void> updateUserBalance(String customUserId, double value) async {
    //updates the balance of a user in the database
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: customUserId)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      // Assuming the custom ID is unique and only one document should match
      var userId = userQuerySnapshot.docs.first.id;
      return users
          .doc(userId)
          .update({'balance': value})
          .then((value) => print("balance Updated"))
          .catchError((error) => print("Failed to update balance: $error"));
    } else {
      print("no user with the id");
    }
  }

  Future<List<Stock>> getUserStocksByCustomId(String customUserId) async {
    //retrieves the user favorited stocks form the databse
    try {
      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Now that you have the Firebase document ID, you can query the 'stocks' sub-collection
        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("FavStocks")
            .get();

        for (var doc in stocksQuerySnapshot.docs) {
          favStocks.add(Stock(name: doc["name"], code: doc["code"]));
        }
        return favStocks;
      } else {
        return favStocks;
      }
    } catch (e) {
      print(e);
      return favStocks;
    }
  }

  Future<String> getUserIdByName(String name) async {
    //retrives the userId by name
    try {
      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('name', isEqualTo: name)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Now that you have the Firebase document ID, you can query the 'stocks' sub-collection

        return userId;
      } else {
        return "";
      }
    } catch (e) {
      print(e);
      return "";
    }
  }

  Future<void> addAStock(String userID, String name, String code) async {
    //adds a stock as favorite to the the user's database
    try {
      QuerySnapshot user = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: userID)
          .get();

      var userId = user.docs.first.id;

      CollectionReference favouritesCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('FavStocks');

      favouritesCollection.add({
        'name': name,
        'code': code,
      });
    } catch (err) {
      print(err);
    }
  }

  Future<void> deleteStock(String customUserId, String stockCode) async {
    //delets a favorited stock from the user database
    try {
      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Now that you have the Firebase document ID, you can query the 'stocks' sub-collection
        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('FavStocks')
            .where('code', isEqualTo: stockCode)
            .get();

        if (stocksQuerySnapshot.docs.isNotEmpty) {
          var stockId = stocksQuerySnapshot.docs.first.id;

          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('FavStocks')
              .doc(stockId)
              .delete();
        } else {}
      } else {}
    } catch (e) {
      print(e);
    }
  }

  Future<void> addTrans(String userID, String code, double price,
      double dollarAmount, double stockAmount) async {
    //adds a new transaction to the databse
    try {
      QuerySnapshot user = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: userID)
          .get();

      var userId = user.docs.first.id;

      CollectionReference favouritesCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Transactions');

      favouritesCollection.add({
        'stockCode': code,
        'stockPrice': price,
        'dollarAmount': dollarAmount,
        'stockAmount': stockAmount,
        'open': 1,
        'profit': 0.0,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (err) {
      print(err);
    }
  }

  Future<List<Trans>> getTransactions(String customUserId) async {
    //retrives transactions of a user from the database
    try {
      // Clear the list each time to prevent duplication
      trans.clear();

      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Query the 'Transactions' sub-collection
        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("Transactions")
            .orderBy("open", descending: true)
            .orderBy("timestamp", descending: true)
            .get();

        // Populate the transactions list with the latest data
        for (var doc in stocksQuerySnapshot.docs) {
          trans.add(Trans(
              code: doc["stockCode"],
              dollarAmount: doc["dollarAmount"],
              priceBought: doc["stockPrice"],
              stockAmount: doc["stockAmount"],
              open: doc["open"] == 1,
              profit: doc["profit"],
              ID: doc.id));
        }
        return trans;
      } else {
        return trans;
      }
    } catch (e) {
      print(e);
      return trans; // Return the potentially cleared or empty list if an error occurs
    }
  }

  Future<void> closeTransaction(
      //close a transaction and update database
      String customUserId,
      double profit,
      String transId) async {
    try {
      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Now that you have the Firebase document ID, you can query the 'stocks' sub-collection
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("Transactions")
            .doc(transId)
            .update({
          "open": 0,
          "profit": profit,
        });

        final DocumentReference userDoc =
            FirebaseFirestore.instance.collection('Users').doc(userId);
        final DocumentSnapshot snapshot = await userDoc.get();

        final double currentTotalProfit = snapshot.get('totalProfit') as double;
        final double newTotalProfit = currentTotalProfit + profit;

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .update({
          "totalProfit": newTotalProfit,
        });
      } else {}
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, double>> getDataForChart(String customUserId) async {
    //retrieves data for portfolio chart from database
    final Map<String, double> dataMap = {};
    try {
      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Query the 'Transactions' sub-collection
        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("Transactions")
            .where("open", isEqualTo: 1)
            .get();

        // Populate the transactions list with the latest data
        for (var doc in stocksQuerySnapshot.docs) {
          if (!dataMap.containsKey(doc['stockCode'])) {
            var currentPrice = await getPrice(doc["stockCode"]);

            dataMap[doc["stockCode"]] = currentPrice * doc["stockAmount"];
          } else {
            var currentPrice = await getPrice(doc["stockCode"]);
            dataMap.update(doc["stockCode"],
                (value) => value + currentPrice * doc["stockAmount"]);
          }
        }
        return dataMap;
      } else {
        return dataMap;
      }
    } catch (e) {
      print(e);
      return dataMap; // Return the potentially cleared or empty list if an error occurs
    }
  }

  Future<Map<String, double>> getSTocksForPerformers(
      //retrieves all stocks for portfolio chart
      String customUserId) async {
    final Map<String, double> stocks = {};
    final Map<String, ProfitHelper> profitHelpers = {};
    try {
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userId = userQuerySnapshot.docs.first.id;

        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("Transactions")
            .where("open", isEqualTo: 1)
            .get();

        for (var doc in stocksQuerySnapshot.docs) {
          String stockCode = doc["stockCode"];
          double stockPrice =
              doc["stockPrice"].toDouble(); // Ensure this is a double
          if (profitHelpers.containsKey(stockCode)) {
            profitHelpers[stockCode]!.nrOfTrans++;
            profitHelpers[stockCode]!.sumOfPrices += stockPrice;
          } else {
            profitHelpers[stockCode] = ProfitHelper(
                code: stockCode, nrOfTrans: 1, sumOfPrices: stockPrice);
          }
        }

        for (var entry in profitHelpers.entries) {
          var stock = entry.value;
          var currentPrice = await getPrice(stock
              .code); // Ensure this function is correctly fetching current price
          double avg = stock.sumOfPrices / stock.nrOfTrans;
          double percentage = ((currentPrice - avg) * 100) / avg;
          stocks[stock.code] = percentage;
        }

        return stocks;
      } else {
        return stocks;
      }
    } catch (e) {
      print(e);
      return stocks;
    }
  }

  Future<double> getUnrealisedProfit(String customUserId) async {
    //retrieves the unrealised profit of a user form the database
    double profit = 0.0;
    try {
      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Query the 'Transactions' sub-collection
        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("Transactions")
            .where("open", isEqualTo: 1)
            .get();

        // Populate the transactions list with the latest data
        for (var doc in stocksQuerySnapshot.docs) {
          var currentPrice = await getPrice(doc["stockCode"]);
          profit =
              profit + (currentPrice - doc["stockPrice"]) * doc["stockAmount"];
        }
        return profit;
      } else {
        return profit;
      }
    } catch (e) {
      print(e);
      return profit; // Return the potentially cleared or empty list if an error occurs
    }
  }

  Future<List<ProfitInTime>> getProfits(String customUserId) async {
    //retirves unrealized profits of a user in the databse
    List<ProfitInTime> profits = [];
    try {
      // Clear the list each time to prevent duplication

      // Query the 'Users' collection to find the document with the matching custom ID
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: customUserId)
          .get();

      // Check if a document with the custom ID exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Assuming the custom ID is unique and only one document should match
        var userId = userQuerySnapshot.docs.first.id;

        // Query the 'Transactions' sub-collection
        QuerySnapshot stocksQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection("Profits")
            .orderBy("day", descending: false)
            .get();

        // Populate the transactions list with the latest data
        for (var doc in stocksQuerySnapshot.docs) {
          Timestamp timestamp =
              doc["day"] as Timestamp; // Cast the Firestore Timestamp
          DateTime day = timestamp.toDate(); // Convert to DateTime
          double profit = doc["profit"]; // Assuming this is already a double

          profits.add(ProfitInTime(day, profit)); // Add to your list
        }
        return profits;
      } else {
        return profits;
      }
    } catch (e) {
      print(e);
      return profits; // Return the potentially cleared or empty list if an error occurs
    }
  }

  Future<double> getPrice(stockCode) async {
    //retrieves the price from the custom API
    try {
      var resp = await http
          .get(Uri.parse('http://10.0.2.2:5000/stock/$stockCode/time/1d'));
      // var resp = await http.get(Uri.parse('https://www.thunderclient.com/welcome'));

      var jsonData = jsonDecode(resp.body);
      return jsonData[0]['Close'];
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<double> getProgess(String customUserId) async {
    //retrives the progress on learning course form the database
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot =
          await users.where('userId', isEqualTo: customUserId).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userDocument = userQuerySnapshot.docs.first;
        double learnProgress = userDocument.get('learnProgress');
        return learnProgress;
      } else {
        print("No user with the id");
        return 0;
      }
    } catch (error) {
      print("Failed to retrieve user balance: $error");
      return 0;
    }
  }

  Future<void> setProgress(String customUserId, double value) async {
    //saves progress of the learning progrss in the database
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: customUserId)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      // Assuming the custom ID is unique and only one document should match
      var userId = userQuerySnapshot.docs.first.id;
      return users
          .doc(userId)
          .update({'learnProgress': value})
          .then((value) => print("Learn Progress Updated"))
          .catchError(
              (error) => print("Failed to update learn progress: $error"));
    } else {
      print("no user with the id");
    }
  }

  Future<void> updateUserName(String customUserId, String newName) async {
    //updates the username of a user in the database
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: customUserId)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      // Assuming the custom ID is unique and only one document should match
      var userId = userQuerySnapshot.docs.first.id;
      return users
          .doc(userId)
          .update({'name': newName})
          .then((name) => print("username Updated"))
          .catchError((error) => print("Failed to update username: $error"));
    } else {
      print("no user with the id");
    }
  }

  Future<String> getUserName(String customUserId) async {
    //extract the username of a user form the database
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot =
          await users.where('userId', isEqualTo: customUserId).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userDocument = userQuerySnapshot.docs.first;
        String userName = userDocument.get('name');
        return userName;
      } else {
        print("No user with the id");
        return "";
      }
    } catch (error) {
      print("Failed to retrieve user name: $error");
      return "";
    }
  }

  Future<void> saveProfilePicture(String customUserId, String picture) async {
    //saves current profile picture to the database
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: customUserId)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      // Assuming the custom ID is unique and only one document should match
      var userId = userQuerySnapshot.docs.first.id;
      return users
          .doc(userId)
          .update({'profilePicture': picture})
          .then((name) => print("pp Updated"))
          .catchError((error) => print("Failed to update pp: $error"));
    } else {
      print("no user with the id");
    }
  }

  Future<String> getProfilePicture(String customUserId) async {
    //returns the profile picture from the database
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot =
          await users.where('userId', isEqualTo: customUserId).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        var userDocument = userQuerySnapshot.docs.first;
        String userName = userDocument.get('profilePicture');
        return userName;
      } else {
        print("No user with the id");
        return "";
      }
    } catch (error) {
      print("Failed to retrieve pp: $error");
      return "";
    }
  }
}
