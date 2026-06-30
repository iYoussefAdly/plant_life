# Tomato Disease Classifier API Documentation

هذا الملف يحتوي على جميع الـ API Endpoints المستخدمة في تطبيق الموبايل (Flutter) والتي تم برمجتها في الباك اند (Node.js/Express).

جميع هذه الـ Endpoints يجب أن يسبقها الـ Base URL الخاص بالـ API:

`https://plant-life-production-8a63.up.railway.app/api`

ملاحظة: في حالة الـ Requests المحمية (Protected Routes)، يجب إرسال الـ Token في الهيدر كالتالي:
`Authorization: Bearer <access_token>`

---

## 1. Authentication & Users (المصادقة والمستخدمين)

### 1.1 تسجيل حساب جديد (Register)
- **Endpoint:** `POST /auth/register`
- **Description:** إنشاء حساب مستخدم جديد.
- **Request Body (JSON):**
  ```json
  {
    "name": "Ahmed",
    "email": "ahmed@example.com",
    "password": "password123"
  }
  ```
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "user_id_here",
        "name": "Ahmed",
        "email": "ahmed@example.com",
        "avatar": null,
        "createdAt": "2023-10-25T10:00:00Z"
      },
      "accessToken": "eyJhbGciOiJIUz...",
      "refreshToken": "def50200..."
    }
  }
  ```

### 1.2 تسجيل الدخول (Login)
- **Endpoint:** `POST /auth/login`
- **Description:** تسجيل الدخول للمستخدمين الحاليين.
- **Request Body (JSON):**
  ```json
  {
    "email": "ahmed@example.com",
    "password": "password123"
  }
  ```
- **Response (Success):** نفس استجابة الـ Register (بيانات المستخدم + Tokens).

### 1.3 تجديد الـ Token (Refresh Token)
- **Endpoint:** `POST /auth/refresh-token`
- **Description:** الحصول على Access Token جديد باستخدام الـ Refresh Token بعد انتهاء صلاحيته.
- **Request Body (JSON):**
  ```json
  {
    "refreshToken": "def50200..."
  }
  ```
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "new_eyJhbGciOiJIUz...",
      "refreshToken": "new_def50200..."
    }
  }
  ```

### 1.4 بيانات المستخدم الحالي (Get Me)
- **Endpoint:** `GET /auth/me`
- **Description:** إرجاع بيانات المستخدم الحالي بناءً على الـ Token.
- **Headers:** `Authorization: Bearer <access_token>`
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "user_id",
        "name": "Ahmed",
        "email": "ahmed@example.com"
      }
    }
  }
  ```

---

## 2. Scans (عمليات الفحص)

### 2.1 فحص أوراق جديدة (Create Scan)
- **Endpoint:** `POST /scans`
- **Description:** إرسال صور أوراق الطماطم لفحصها بالذكاء الاصطناعي.
- **Headers:** `Content-Type: multipart/form-data`, `Authorization: Bearer <access_token>`
- **Request Body (FormData):**
  - `images`: مصفوفة من الملفات (Array of image files).
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "scan": {
        "_id": "scan_id",
        "images": [
          { "url": "https://...", "publicId": "...", "filename": "image_0.jpg" }
        ],
        "result": {
          "tree_status": "Diseased",
          "tree_status_ar": "مصابة",
          "is_infected": true,
          "main_disease": "Early_blight",
          "avg_severity_all_images": 65.5,
          "per_image_details": [
            {
              "filename": "image_0.jpg",
              "disease": "Early_blight",
              "confidence": 0.98,
              "severity_percent": 70.0
            }
          ]
        },
        "createdAt": "2023-10-25T10:15:00Z"
      }
    }
  }
  ```

### 2.2 عرض سجل الفحوصات (List Scans)
- **Endpoint:** `GET /scans`
- **Description:** جلب قائمة بالفحوصات السابقة للمستخدم مع دعم الـ Pagination.
- **Query Params:** `page` (رقم الصفحة), `limit` (عدد العناصر), `q` (كلمة البحث).
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "scans": [ /* مصفوفة من الفحوصات */ ],
      "pagination": { "page": 1, "limit": 10, "totalPages": 2, "total": 15 }
    }
  }
  ```

### 2.3 تفاصيل فحص معين (Get Scan)
- **Endpoint:** `GET /scans/:id`
- **Description:** جلب تفاصيل فحص واحد عن طريق الـ ID الخاص به.

### 2.4 إعادة الفحص للمتابعة (Rescan)
- **Endpoint:** `POST /scans/:parentScanId/rescan`
- **Description:** عمل فحص جديد مرتبط بفحص قديم لمعرفة مدى تحسن النبات.
- **Request Body (FormData):** `images` (نفس طريقة Create Scan).
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "scan": { /* تفاصيل الفحص الجديد */ },
      "comparison": {
        "severityDelta": -15.5,
        "improved": true,
        "parentSeverity": 80.0,
        "currentSeverity": 64.5
      }
    }
  }
  ```

---

## 3. Heal Plans (خطط العلاج)

### 3.1 عرض القوالب المتاحة (Get Templates)
- **Endpoint:** `GET /heal-plans/templates`
- **Description:** جلب جميع قوالب العلاج المتاحة للأمراض المختلفة.
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "templates": [
        { "disease": "Early_blight", "disease_display": "اللفحة المبكرة", "totalDays": 14, "taskCount": 5 }
      ]
    }
  }
  ```

### 3.2 تفعيل خطة علاج لفحص (Accept Plan)
- **Endpoint:** `POST /heal-plans`
- **Description:** بدء خطة علاج بناءً على نتيجة فحص مصاب.
- **Request Body (JSON):**
  ```json
  { "scanId": "scan_id_here" }
  ```
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "healPlan": {
        "_id": "plan_id",
        "disease": "Early_blight",
        "status": "active",
        "progress": 0,
        "tasks": [
          {
            "day": 1,
            "title": "إزالة الأوراق المصابة",
            "description": "قم بقص جميع الأوراق التي تظهر عليها بقع بنية.",
            "completed": false,
            "scheduledDate": "2023-10-26T00:00:00Z"
          }
        ]
      }
    }
  }
  ```

### 3.3 عرض خطط العلاج (List Plans)
- **Endpoint:** `GET /heal-plans`
- **Description:** جلب قائمة خطط العلاج للمستخدم.
- **Query Params:** `page`, `limit`, `status` (يمكن أن يكون `active`, `completed`, `cancelled`).

### 3.4 تفاصيل خطة العلاج (Get Plan)
- **Endpoint:** `GET /heal-plans/:id`
- **Description:** جلب تفاصيل ومهام خطة علاج محددة.

### 3.5 إكمال أو إلغاء مهمة في الخطة (Toggle Task)
- **Endpoint:** `PATCH /heal-plans/:planId/tasks/:taskIndex`
- **Description:** تغيير حالة المهمة (Task) داخل خطة العلاج بين مكتملة وغير مكتملة. (الـ taskIndex يبدأ من 0).
- **Response (Success):** يرجع الخطة العلاجية محدثة.

### 3.6 إلغاء الخطة (Cancel Plan)
- **Endpoint:** `PATCH /heal-plans/:id/cancel`
- **Description:** إيقاف وإلغاء خطة علاج نشطة.

---

## 4. Notifications (الإشعارات)

### 4.1 عرض الإشعارات (List Notifications)
- **Endpoint:** `GET /notifications`
- **Description:** جلب سجل الإشعارات الخاصة بالمستخدم.
- **Query Params:** `page`, `limit`, `read` (لتصفية المقروء أو غير المقروء).
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": {
      "notifications": [
        {
          "_id": "notif_id",
          "type": "task_reminder",
          "title": "تذكير بمهمة اليوم",
          "message": "حان وقت رش المبيد الفطري.",
          "read": false,
          "createdAt": "2023-10-26T08:00:00Z"
        }
      ],
      "pagination": { "page": 1, "limit": 20, "totalPages": 1, "total": 1 }
    }
  }
  ```

### 4.2 عدد الإشعارات غير المقروءة (Get Unread Count)
- **Endpoint:** `GET /notifications/unread-count`
- **Description:** جلب رقم يمثل عدد الإشعارات التي لم يقرأها المستخدم بعد (لعرضه كـ Badge).
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": { "count": 3 }
  }
  ```

### 4.3 تحديد إشعار كمقروء (Mark As Read)
- **Endpoint:** `PATCH /notifications/:id/read`
- **Description:** تحويل حالة الإشعار إلى مقروء (`read: true`).

### 4.4 تحديد الكل كمقروء (Mark All As Read)
- **Endpoint:** `PATCH /notifications/read-all`
- **Description:** جعل جميع إشعارات المستخدم مقروءة مرة واحدة.
- **Response (Success):**
  ```json
  {
    "success": true,
    "data": { "modifiedCount": 3 }
  }
  ```

---
**تم إعداد هذا الملف لتسهيل ربط تطبيق الـ Flutter مع نفس الـ API الخاص بـ Tomato Disease Classifier.**
