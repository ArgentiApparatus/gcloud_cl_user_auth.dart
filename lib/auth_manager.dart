// Copyright (c) 2016, Gary Smith. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library gcloud_cl_user_auth_manager;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart'               as http;

import 'package:gcloud_cl_user_auth/user_creds_encoding.dart';


// TODO: Error handling


Future<AuthMgr> getAuthMgr(File userCredsFile) async {
  return new AuthMgr._(new http.Client(), userCredsFile, decodeUserCreds(JSON.decode(await userCredsFile.readAsString())));
}


class AuthMgr {

  final http.Client _baseClient;
  final File _userCredsFile;
  final UserCreds _userCreds;
  final auth.AutoRefreshingAuthClient autoAuthClient;
  final auth.AuthClient authClient;


  AuthMgr._(http.Client baseClient, File userCredsFile, UserCreds userCreds):
    _baseClient = baseClient,
    _userCredsFile = userCredsFile,
    _userCreds = userCreds,
    autoAuthClient = auth.autoRefreshingClient(userCreds.clientId, userCreds.accessCredentials, baseClient),
    authClient = auth.authenticatedClient(baseClient, userCreds.accessCredentials) {

    StreamSubscription sub = autoAuthClient.credentialUpdates.listen((newAccessCreds) async {
      _userCreds.accessCredentials = newAccessCreds;
      try {
        await _userCredsFile.writeAsString(JSON.encode(encodeUserCreds(_userCreds)), flush: true);
      } catch(e) {
        // TODO: Something here
        //if(onFuckup != null) {
        //  sub.cancel();
        //  onFuckup(e);
      }
    });
  }

  void close() {
    _baseClient.close();
  }
}










