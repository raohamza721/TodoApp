
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget{
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _expenseAndIncomeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _AddExpensesAndAmount() async {
    String expenseIncomeName = _expenseAndIncomeController.text.trim();
    String amount = _amountController.text.trim();

    if (expenseIncomeName.isNotEmpty && amount.isNotEmpty) {
      DocumentReference docRef = firestore.collection('expenseTrack').doc();
      await docRef.set({
        'expensesAndIncome': expenseIncomeName,
        'ExpenseId': docRef.id,
        'amount': amount,
        'created_at': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense/Amount Added')),
      );
      _expenseAndIncomeController.clear();
      _amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Enter Your Data')),
      );
    }
  }

  Map<String, double> calculateTotals(List<QueryDocumentSnapshot> data) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var doc in data) {
      double amount = double.tryParse(doc['amount']) ?? 0.0;

      (amount > 0) ? totalIncome += amount : totalExpense += amount;
    }
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome + totalExpense,
    };
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Expense Tracker",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(right: 100.0),
                child: Text(
                  "Your Balance",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('expenseTrack').orderBy('created_at', descending: false).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var data = snapshot.data!.docs;
                  var totals = calculateTotals(data);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Rs: ",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            totals['balance']!.toStringAsFixed(2), // Display balance
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SizedBox(
                              height: 100,
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Income'),
                                  Text(totals['totalIncome']!.toStringAsFixed(2)), // Display total income
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SizedBox(
                              height: 100,
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Expense'),
                                  Text(totals['totalExpense']!.toStringAsFixed(2)), // Display total expense
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 250,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: const Icon(Icons.monetization_on_rounded),
                                title: Text(data[index]['expensesAndIncome']),
                                trailing: Text(
                                  'Rs: ${data[index]['amount']}',
                                  style: TextStyle(
                                      color: double.parse(data[index]['amount']) > 0 ? Colors.green : Colors.red),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Text(
                'Add new Transaction',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _expenseAndIncomeController,
                decoration: InputDecoration(
                  labelText: 'EXPENSE/INCOME NAME',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _AddExpensesAndAmount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
