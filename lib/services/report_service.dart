import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';

class ReportService {
  static Future<void> generatePdfReport(List<HistoryItem> history) async {
    final pdf = pw.Document();
    final dateNow = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header Laporan
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "LAPORAN MONITORING AIR - SIPABERSIH",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  pw.Text(dateNow),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabel Data (Versi Paling Kompatibel)
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Waktu', 'pH', 'TDS', 'Kekeruhan', 'Status'],
              data: List<List<dynamic>>.generate(
                history.length,
                (index) => [
                  index + 1,
                  DateFormat(
                    'dd/MM HH:mm',
                  ).format(history[index].measure.timestamp),
                  history[index].measure.ph.toStringAsFixed(1),
                  "${history[index].measure.tds.toInt()} ppm",
                  "${history[index].measure.turbidity.toInt()} NTU",
                  history[index].result.status,
                ],
              ),
              // Styling Header
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              // Styling Cell
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 10),
              // Kita hapus oddRowDecoration dan evenRowDecoration untuk menghindari error versi
            ),

            pw.SizedBox(height: 40),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text(
                    "Dicetak secara otomatis melalui Sistem SIPABERSIH",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 50),
                  pw.Text(
                    "__________________________",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text("Petugas Lapangan"),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Menampilkan preview PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_SIPABERSIH.pdf',
    );
  }
}
