// Copyright (c) 2016, Gary Smith. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library gcloud_cl_user_auth_creds_encoding;

import "package:googleapis_auth/auth.dart";

// TODO: Error handling

Map<String, dynamic> encodeClientId(ClientId clientId) => {
  'identifier': clientId.identifier,
  'secret': clientId.secret
};


ClientId decodeClientId(Map<String, dynamic> map) =>
  new ClientId(map['identifier']?.trim(),
               map['secret']?.trim());


Map<String, dynamic> encodeAccessCredentials(AccessCredentials creds) => {
  'accessToken': encodeAccessToken(creds.accessToken),
  'refreshToken': creds.refreshToken,
  'scopes': creds.scopes
};


AccessCredentials decodeAccessCredentials(Map<String, dynamic> map) =>
  new AccessCredentials(decodeAccessToken(map['accessToken']),
                        map['refreshToken']?.trim(),
                        decodeScopes(map['scopes']));


Map<String, dynamic> encodeAccessToken(AccessToken token) => {
  'type': token.type,
  'data': token.data,
  'expiry': token.expiry.toIso8601String()
};


AccessToken decodeAccessToken(Map<String, dynamic> map) =>
  new AccessToken(map['type']?.trim(),
                  map['data']?.trim(),
                  DateTime.parse(map['expiry']));


List<String> decodeScopes(Iterable<String> list) =>
  new List<String>.from(list.map((s) => s.trim()).where((s) => s.isNotEmpty));


Map<String, dynamic> encodeUserCreds(UserCreds credulous) => {
  'clientId': encodeClientId(credulous.clientId),
  'user': credulous.user,
  'accessCredentials': encodeAccessCredentials(credulous.accessCredentials),
  'refreshed': credulous.refreshed.toIso8601String()
};


UserCreds decodeUserCreds(Map<String, dynamic> map) {
  return new UserCreds(decodeClientId(map['clientId']),
                       map['user'].trim(),
                       decodeAccessCredentials(map['accessCredentials']),
                       DateTime.parse(map['refreshed']));
}


class UserCreds {

  ClientId clientId;
  String user;
  AccessCredentials accessCredentials;
  DateTime refreshed;

  UserCreds(this.clientId, this.user, this.accessCredentials, this.refreshed);
}


