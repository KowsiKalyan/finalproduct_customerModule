import 'package:jaguar_jwt/jaguar_jwt.dart';
import '../Helper/Constant.dart';

String getToken() {
  final claimSet = JwtClaim(
    issuer: issuerName,
    maxAge: const Duration(minutes: tokenExpireTime),
    issuedAt: DateTime.now().toUtc(),
  );
  String token = issueJwtHS256(claimSet, jwtKey);

  print(token);
  return token;
}

Map<String, String> get headers => {
      'Authorization': 'Bearer ${getToken()}',
    };
