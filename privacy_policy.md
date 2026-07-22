# Privacy Policy for BIPM FOR FAW

**Last Updated:** July 22, 2026  
**Effective Date:** July 22, 2026  

---

## 1. Introduction

Welcome to **BIPM FOR FAW** ("we," "our," or "us"). We are committed to protecting the privacy of our users ("you" or "farmer"). 

BIPM FOR FAW is a mobile application developed using the Flutter framework designed to assist farmers, agricultural extension workers, and researchers in identifying **Fall Armyworm (*Spodoptera frugiperda*)** infestations and assessing crop health.

This Privacy Policy explains how we handle data when you use the BIPM FOR FAW mobile application. By installing and using BIPM FOR FAW, you consent to the practices described in this Privacy Policy.

---

## 2. Information We Collect

### A. Personal Data
* **No Account Required:** We do **not** collect names, email addresses, phone numbers, passwords, postal addresses, or payment details. You can use the application without registering or providing any personally identifiable information (PII).

### B. User-Provided Content (Crop Images)
* **Photos for AI Analysis:** When you photograph a crop leaf or pest using the app's camera feature or select an image from your device gallery, that image is temporarily uploaded to our secure inference server to generate an AI-powered diagnostic prediction.

### C. Automatically Generated Technical Data
* **Device & API Diagnostics:** To process inference requests and maintain server security, our backend HTTP server receives basic network protocol metadata (such as IP addresses and server log timestamps). We do not correlate IP addresses with individual user profiles, nor do we track your identity across other applications or websites.

---

## 3. How We Use Information

We use the images you upload and technical request data strictly for the following purposes:

1. **AI Crop Diagnosis:** Transmitting uploaded crop images to our inference model pipeline to determine crop health status, detect Fall Armyworm infestation, and return relevant diagnostic confidence scores.
2. **Agricultural Guidance Generation:** Providing structured treatment and control guidance steps based on the AI diagnostic result.
3. **App Stability & Security:** Monitoring server request logs to protect our infrastructure against abusive requests, cyber threats, and rate-limit violations.

---

## 4. Permissions Requested

BIPM FOR FAW requests specific runtime permissions on your mobile device to deliver its core functionality:

* **Camera Permission (`android.permission.CAMERA`):**
  * *Purpose:* Required to allow you to take real-time photos of crop leaves, damage symptoms, or insects directly within the application for AI evaluation.
* **Storage / Photo Access (`android.permission.READ_EXTERNAL_STORAGE` / Photo Picker):**
  * *Purpose:* Required to allow you to select previously taken crop photos from your device library for AI evaluation.
* **Internet Access (`android.permission.INTERNET`):**
  * *Purpose:* Required to send compressed image payloads over encrypted HTTPS to our cloud-hosted backend inference service (`https://faw-backend.onrender.com`) and retrieve diagnostic results.

> **Note:** You can grant or revoke Camera and Storage permissions at any time through your device's Android System Settings. If you deny Camera or Photo access, you will be unable to capture or select images for AI analysis.

---

## 5. Data Transmission & HTTPS Security

* **Encrypted Transport:** All communication between the BIPM FOR FAW Flutter application and our backend server is conducted using **Transport Layer Security (TLS/HTTPS)**. This ensures that your uploaded crop images and the returned diagnostic predictions are encrypted in transit.
* **Cloud Infrastructure:** Our backend application and AI models are hosted on **Render** (Render Services, Inc.). Render manages physical server security and infrastructure controls.

---

## 6. Local Storage & Data Retention

* **On-Device Scan History:** The application saves recent scan records (including local thumbnail image paths, diagnosis labels, confidence scores, and timestamps) **locally on your physical device** using key-value storage (`SharedPreferences`).
* **Control of Local Data:** Scan history remains entirely on your device. You can clear this data at any time by clearing the application's data or uninstalling the app via your device settings.
* **Image Retention on Backend:** Images uploaded for AI inference are processed transiently in memory to perform classification and treatment matching. We do not sell your images, build user profiling databases, or share uploaded photos with third-party data brokers.

---

## 7. Advertising & Data Sale Policy

* **No Advertisements:** BIPM FOR FAW contains zero third-party advertising, banner ads, or promotional SDKs.
* **No Data Selling:** We **never** sell, rent, monetize, or trade your uploaded images, scan history, or device data to any third parties or data brokers.
* **No User Tracking:** We do not use cross-site tracking technologies, advertising IDs (GAID), or behavioral profiling tools.

---

## 8. Third-Party Services & SDKs

The app uses minimal open-source software libraries and cloud platform infrastructure necessary to support Flutter compilation and backend execution:

* **Flutter Framework & Plugins:** Standard Flutter infrastructure packages developed by the Flutter community (e.g., `image_picker`, `flutter_image_compress`, `http`, `connectivity_plus`).
* **Firebase Core Infrastructure:** The application initializes standard Firebase core SDKs (`firebase_core`) for client application lifecycle management. No telemetry profiles or commercial analytics pipelines are linked to your identity.
* **Cloud Hosting:** Backend API endpoints hosted on Render (`render.com`).

---

## 9. Children's Privacy (COPPA & GDPR Compliance)

BIPM FOR FAW is an agricultural utility tool designed for general audiences, farmers, and agricultural workers. We do not knowingly target or collect personal information from children under the age of 13 (or under 16 in certain jurisdictions). 

Because the app requires no user registration or personal identification inputs, no personal details belonging to children are requested or stored. If a parent or guardian becomes aware that a child has provided us with personal information, please contact us so we can take immediate corrective measures.

---

## 10. Agricultural Disclaimer & Advisory Notice

> **IMPORTANT DISCLAIMER:**  
> The diagnostic outputs, confidence scores, and treatment plans provided by BIPM FOR FAW are generated by artificial intelligence algorithms and are provided for **informational and educational purposes only**. 
>
> While every effort is made to train robust diagnostic models, AI predictions can occasionally be inaccurate, affected by poor lighting, blur, or unexpected visual artifacting. AI predictions **do not replace professional agronomic consultation**. Farmers and users should verify results with local agricultural extension officers, certified agronomists, or official plant health authorities before purchasing or applying chemical or biological control measures.

---

## 11. User Data Rights & Data Deletion

Under privacy frameworks such as GDPR and CCPA, users have specific rights regarding their personal data. 

Because BIPM FOR FAW does **not** create user accounts or store identifiable personal profiles on external cloud databases:
* **Local Data Removal:** All stored scan history and cached diagnostic records exist exclusively on your device. You can exercise your right to delete this data instantly by choosing **Clear Storage / Clear Data** under `Settings > Apps > BIPM FOR FAW` on your Android device, or by uninstalling the application.
* **Data Requests:** If you have questions regarding data processing or server infrastructure, you may submit a inquiry to our contact email below.

---

## 12. Changes to This Privacy Policy

We may update our Privacy Policy from time to time to reflect changes in our legal obligations, backend service upgrades, or Google Play policy updates. 

Any updates will be posted directly within this document with a revised "Last Updated" date. We encourage users to review this policy periodically. Continued use of the application following the posting of changes constitutes acceptance of those changes.

---

## 13. Contact Us

If you have any questions, concerns, or requests regarding this Privacy Policy or our privacy practices, please contact us at:

* **Organization / Publisher:** ICAR - National Bureau of Agricultural Insect Resources (NBAIR)
* **Contact Email:** director.nbair@icar.gov.in
* **Website / Project Repository:** https://nbair.icar.gov.in
* **Address:** P.B. No. 2491, H.A. Farm Post, Bellary Road, Hebbal, Bengaluru - 560024, Karnataka, India
