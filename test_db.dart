import 'dart:io';
import 'package:postgres/postgres.dart';

void main() async {
  const dbUrl = 'postgresql://neondb_owner:npg_V2Bnuz5xFpYe@ep-nameless-bird-a1pl9bnj-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require';
  
  final uri = Uri.parse(dbUrl);
  final endpoint = Endpoint(
    host: uri.host,
    database: uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : 'postgres',
    username: uri.userInfo.split(':')[0],
    password: uri.userInfo.split(':')[1],
    port: uri.hasPort ? uri.port : 5432,
  );

  final conn = await Connection.open(
    endpoint,
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );

  final result = await conn.execute('SELECT * FROM operations_assignment');
  print('Total assignments in DB: ${result.length}');
  
  for (var r in result) {
    print(r.toColumnMap());
  }

  await conn.close();
}
