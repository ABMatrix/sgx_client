
import 'dart:convert';

class QuoteReport {
  final String id;
  final String timestamp;
  final String version;
  final String isvEnclaveQuoteStatus;
  final String platformInfoBlob;
  final String isvEnclaveQuoteBody;

  QuoteReport(this.id, this.timestamp, this.version, this.isvEnclaveQuoteStatus,
      this.platformInfoBlob, this.isvEnclaveQuoteBody);
      

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'version': version,
      'isvEnclaveQuoteStatus': isvEnclaveQuoteStatus,
      'platformInfoBlob': platformInfoBlob,
      'isvEnclaveQuoteBody': isvEnclaveQuoteBody,
    };
  }

  factory QuoteReport.fromMap(Map<String, dynamic> map) {
    return QuoteReport(
      map['id'],
      map['timestamp'],
      map['version'],
      map['isvEnclaveQuoteStatus'],
      map['platformInfoBlob'],
      map['isvEnclaveQuoteBody'],
    );
  }

  String toJson() => json.encode(toMap());

  factory QuoteReport.fromJson(String source) => QuoteReport.fromMap(json.decode(source));
}
