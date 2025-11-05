import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (web-style)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                      const SizedBox(height: 6),
                      Text('Overview of customers and shop transactions', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green[700],
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Summary row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Current Balance', style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 8),
                                Text('12,300.00 ฿', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text('+ 18,000.00 ฿', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('- 5,700.00 ฿', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add Txn'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Small line chart card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Transactions Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 3,
                                spots: const [
                                  FlSpot(0, 1),
                                  FlSpot(1, 3),
                                  FlSpot(2, 2),
                                  FlSpot(3, 5),
                                  FlSpot(4, 3.5),
                                  FlSpot(5, 4),
                                  FlSpot(6, 7),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Recent transactions list
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Column(
                children: [
                  _recentTile('Shopping at Market', '24/08/2025', -250.50),
                  _recentTile('Electricity Bill', '20/08/2025', -1200.00),
                  _recentTile('Salary', '01/08/2025', 15000.00),
                ],
              ),

              const SizedBox(height: 18),

              // Heatmap (kept from original)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 245, 222),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HeatMapCalendar(
                    defaultColor: const Color.fromARGB(255, 255, 255, 255),
                    flexible: true,
                    colorMode: ColorMode.color,
                    textColor: Colors.black,
                    datasets: {
                      DateTime(2025, 8, 1): 3,
                      DateTime(2025, 8, 3): 7,
                      DateTime(2025, 8, 6): 5,
                      DateTime(2025, 8, 10): 10,
                      DateTime(2025, 8, 12): 2,
                      DateTime(2025, 8, 15): 8,
                    },
                    colorsets: const {
                      1: Colors.green,
                      3: Colors.greenAccent,
                      5: Colors.orange,
                      7: Colors.deepOrange,
                      10: Colors.red,
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentTile(String title, String date, double amount) {
    final isIncome = amount > 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: const TextStyle(color: Colors.black54)),
        trailing: Text('${isIncome ? '+' : '-'}${amount.abs().toStringAsFixed(2)} ฿', style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red)),
        onTap: () {
          // placeholder: open transaction detail
        },
      ),
    );
  }
}
