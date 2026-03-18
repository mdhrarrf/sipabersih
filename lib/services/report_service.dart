import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';

class ReportService {
  static Future<void> generatePdfReport({
    required List<HistoryItem> history,
    required String officerName,
    required String officerId,
  }) async {
    final pdf = pw.Document();
    final dateNow = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        // PERBAIKAN: PdfPageFormat dipanggil langsung tanpa prefix 'pw.'
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // 1. HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "LAPORAN MONITORING KUALITAS AIR",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      "Sistem Informasi SIPABERSIH PRO - Tanggap Bencana",
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 2, color: PdfColors.blue900),
            pw.SizedBox(height: 20),

            // 2. RINGKASAN INFORMASI
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 100,
                        child: pw.Text(
                          "Petugas",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Text(": $officerName"),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 100,
                        child: pw.Text(
                          "ID Petugas",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Text(": $officerId"),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 100,
                        child: pw.Text(
                          "Tanggal Cetak",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Text(": $dateNow"),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 25),

            // 3. TABEL DATA
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Waktu Pengukuran', 'pH', 'TDS', 'NTU', 'Status'],
              data: List<List<dynamic>>.generate(
                history.length,
                (index) => [
                  index + 1,
                  DateFormat(
                    'dd/MM/yy HH:mm',
                  ).format(history[index].measure.timestamp),
                  history[index].measure.ph.toStringAsFixed(1),
                  "${history[index].measure.tds.toInt()} ppm",
                  "${history[index].measure.turbidity.toInt()} NTU",
                  history[index].result.status,
                ],
              ),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.all(7),
            ),

            pw.SizedBox(height: 50),

            // 4. PENGESAHAN
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text("Dokumen ini dihasilkan secara otomatis,"),
                  pw.Text("oleh Sistem Monitoring SIPABERSIH PRO"),
                  pw.SizedBox(height: 60),
                  pw.Container(width: 150, child: pw.Divider(thickness: 1)),
                  pw.Text(
                    officerName,
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

    // 5. PROSES CETAK
    await Printing.layoutPdf(
      // PERBAIKAN: PdfPageFormat dipanggil langsung tanpa prefix 'pw.'
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_SIPAPRO_${officerId}.pdf',
    );
  }
}
