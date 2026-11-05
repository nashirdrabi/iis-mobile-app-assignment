"""Explicit live checks using a disposable Firebase account; no tokens are saved.
Run: python3 tool/verify_firebase_backend.py --run-live
"""
import argparse
import datetime
import json
import secrets
import urllib.error
import urllib.request
import uuid
from pathlib import Path

class ServiceError(Exception):
    def __init__(self, status, code):
        self.status, self.code = status, code
        super().__init__(code)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run-live', action='store_true', help='Create and delete temporary test data in the configured Firebase project')
    args = parser.parse_args()
    if not args.run_live:
        parser.error('--run-live is required; this check creates disposable backend test data')
    root = Path(__file__).resolve().parents[1]
    config = json.loads((root / 'android/app/google-services.json').read_text())
    project = config['project_info']['project_id']
    key = config['client'][0]['api_key'][0]['current_key']
    base = 'https://identitytoolkit.googleapis.com/v1/'
    report = {'project': project, 'checkedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'checks': []}
    def note(name, result='passed', reason=None):
        row = {'check': name, 'result': result}
        if reason: row['reason'] = reason
        report['checks'].append(row)
    def request(url, data=None, token=None, method=None):
        headers = {'Content-Type': 'application/json'}
        if token: headers['Authorization'] = 'Bearer ' + token
        req = urllib.request.Request(url, data=None if data is None else json.dumps(data).encode(), headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=25) as response:
                content = response.read()
                return json.loads(content) if content else {}
        except urllib.error.HTTPError as error:
            payload = json.loads(error.read()).get('error', {})
            raise ServiceError(error.code, payload.get('status', payload.get('message', 'HTTP_ERROR')).split(' : ')[0]) from None
    def create_temporary_account():
        email = 'iis-assignment-check-' + uuid.uuid4().hex[:12] + '@example.test'
        password = secrets.token_urlsafe(24)
        response = request(base + 'accounts:signUp?key=' + key, {'email': email, 'password': password, 'returnSecureToken': True})
        return response, email, password
    def expect_denied(name, action):
        try:
            action()
            note(name, 'failed', 'The request was unexpectedly allowed')
        except ServiceError as error:
            note(name, 'passed' if error.status == 403 else 'failed', None if error.status == 403 else error.code)
    token = secondary_token = doc = None
    try:
        user, email, password = create_temporary_account()
        token = user['idToken']
        note('Firebase Auth registration')
        signed = request(base + 'accounts:signInWithPassword?key=' + key, {'email': email, 'password': password, 'returnSecureToken': True})
        token = signed['idToken']
        note('Firebase Auth sign-in')
        try:
            request(base + 'accounts:signInWithPassword?key=' + key, {'email': email, 'password': 'deliberately-incorrect', 'returnSecureToken': True})
            note('Incorrect password rejected', 'failed')
        except ServiceError as error:
            note('Incorrect password rejected', 'passed' if error.status == 400 else 'failed')
        uid = user['localId']
        doc = f'https://firestore.googleapis.com/v1/projects/{project}/databases/(default)/documents/users/{uid}'
        fields = {'uid': {'stringValue': uid}, 'email': {'stringValue': email}, 'displayName': {'stringValue': 'Assignment Verification'}, 'onboardingComplete': {'booleanValue': False}}
        request(doc, {'fields': fields}, token, 'PATCH')
        assert request(doc, token=token)['fields']['onboardingComplete']['booleanValue'] is False
        note('Firestore profile create/read')
        fields['onboardingComplete'] = {'booleanValue': True}
        request(doc, {'fields': fields}, token, 'PATCH')
        assert request(doc, token=token)['fields']['onboardingComplete']['booleanValue'] is True
        note('Firestore onboarding update/read')
        expect_denied('Unauthenticated profile access denied', lambda: request(doc))
        other, _, _ = create_temporary_account()
        secondary_token = other['idToken']
        expect_denied('Other authenticated account profile access denied', lambda: request(doc, token=secondary_token))
        expect_denied('Forged profile UID rejected', lambda: request(doc, {'fields': {**fields, 'uid': {'stringValue': 'another-account'}}}, token, 'PATCH'))
        expect_denied('Invalid onboarding field type rejected', lambda: request(doc, {'fields': {**fields, 'onboardingComplete': {'stringValue': 'yes'}}}, token, 'PATCH'))
    except Exception as error:
        note('Backend verification', 'blocked', error.code if isinstance(error, ServiceError) else type(error).__name__)
    finally:
        if doc and token:
            try:
                request(doc, token=token, method='DELETE')
                note('Temporary profile cleanup')
            except Exception as error: note('Temporary profile cleanup', 'blocked', type(error).__name__)
        for label, credential in [('Temporary auth account cleanup', token), ('Secondary test account cleanup', secondary_token)]:
            if credential:
                try:
                    request(base + 'accounts:delete?key=' + key, {'idToken': credential})
                    note(label)
                except Exception as error: note(label, 'blocked', type(error).__name__)
    output = root / 'docs/verification/firebase_backend.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    return 0 if all(check['result'] == 'passed' for check in report['checks']) else 1

if __name__ == '__main__':
    raise SystemExit(main())
