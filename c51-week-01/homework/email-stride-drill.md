# Email STRIDE Drill

## STRIDE threats

### 1. Spoofing — Someone impersonates you

**Threat:** An attacker steals your password or active login session through phishing, then signs in and sends messages that appear to come from your email address.

**Mitigation:** Use a passkey or phishing-resistant multi-factor authentication (MFA), and never approve unexpected sign-in prompts.

### 2. Tampering — Someone secretly changes your mail handling

**Threat:** An attacker creates or modifies a filter or forwarding rule so that certain messages are automatically moved, deleted, marked as read, or sent to an address they control.

**Mitigation:** Periodically review your filters, forwarding addresses, and mail rules, and remove anything you did not create.

### 3. Repudiation — A harmful action cannot be reliably traced

**Threat:** Someone who has access to your account sends or deletes messages, then claims they did not do it, while you have no useful record of the sign-in or account activity.

**Mitigation:** Enable available security notifications and regularly review the account's recent sign-in and device activity so suspicious actions are easier to identify.

### 4. Information Disclosure — Private messages are exposed

**Threat:** An OAuth-connected third-party app is granted broad mailbox access and later exposes or misuses the messages and attachments it can read.

**Mitigation:** Review the apps and services connected to your email account, revoke access you no longer need, and avoid granting mailbox permissions unless they are necessary.


### 5. Denial of Service — You lose access to your mailbox

**Threat:** An attacker repeatedly triggers sign-in attempts or floods the mailbox with unwanted messages, making the account difficult to use or causing you to lose access temporarily.

**Mitigation:** Keep your recovery options current, use a unique password and MFA, and monitor mailbox storage so you can respond to account-access or storage warnings.

### 6. Elevation of Privilege — An attacker gains control beyond ordinary access

**Threat:** After compromising your account or its recovery channel, an attacker changes recovery details or security settings, adds their own authentication method, and makes it harder for you to regain control.

**Mitigation:** Protect your recovery email and phone number, keep recovery details up to date, use MFA, and review account security settings for unfamiliar changes.

## Quick entry-point checklist

- **Login:** Is MFA or a passkey enabled? Is the password unique?
- **Filters and forwarding:** Are there unfamiliar rules, forwarding addresses, or automatic deletions?
- **Connected apps:** Which third-party apps can read, send, or manage your email?
- **Devices and sessions:** Are there unfamiliar signed-in devices or active sessions?
- **Recovery options:** Are the recovery email address and phone number yours and still accessible?
- **Security activity:** Are there unfamiliar sign-ins, security alerts, or changes to account settings?

