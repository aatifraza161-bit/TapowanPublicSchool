-- Table: Users
-- Stores information about all system users (Admins, Teachers, Students, Staff)
CREATE TABLE Users (
    user_id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Store hashed passwords, never plain text
    role VARCHAR(50) NOT NULL, -- e.g., 'Admin', 'Teacher', 'Student', 'Staff'
    full_name VARCHAR(255),
    phone_number VARCHAR(20),
    address TEXT,
    status VARCHAR(20) DEFAULT 'Active', -- 'Active', 'Inactive'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Students
-- Stores detailed information about students
CREATE TABLE Students (
    student_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE, -- Link to Users table if students have login accounts
    full_name VARCHAR(255) NOT NULL,
    father_name VARCHAR(255),
    mother_name VARCHAR(255),
    class_name VARCHAR(50), -- e.g., 'Grade 10', 'Grade 9'
    roll_no VARCHAR(50) UNIQUE,
    aadhar_no VARCHAR(50) UNIQUE,
    email VARCHAR(255),
    phone_number VARCHAR(20),
    status VARCHAR(20) DEFAULT 'Active', -- 'Active', 'Inactive'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Teachers
-- Stores detailed information about teachers
CREATE TABLE Teachers (
    teacher_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE, -- Link to Users table
    full_name VARCHAR(255) NOT NULL,
    subject VARCHAR(100), -- e.g., 'Mathematics', 'English'
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    classes_taught TEXT, -- e.g., 'Grade 9-10', 'Grade 11-12'
    status VARCHAR(20) DEFAULT 'Active', -- 'Active', 'Inactive'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Payroll
-- Records payroll processing details
CREATE TABLE Payroll (
    payroll_id VARCHAR(50) PRIMARY KEY,
    payroll_period VARCHAR(50) NOT NULL, -- e.g., 'March 2023'
    staff_count INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Processing', -- 'Processing', 'Paid', 'Failed'
    processed_by_user_id VARCHAR(50),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (processed_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Invoices
-- Records financial invoices
CREATE TABLE Invoices (
    invoice_id VARCHAR(50) PRIMARY KEY,
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    invoice_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL, -- 'Paid', 'Pending', 'Overdue'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Announcements
-- Stores school-wide announcements
CREATE TABLE Announcements (
    announcement_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    date_posted DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Active', -- 'Active', 'Archived'
    posted_by_user_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (posted_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Notifications
-- Stores system notifications for users
CREATE TABLE Notifications (
    notification_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50), -- NULL if general notification
    title VARCHAR(255) NOT NULL,
    description TEXT,
    time_ago VARCHAR(100), -- e.g., '5 minutes ago', '1 hour ago' - consider storing actual timestamp
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Table: AuditLogs
-- Records system activities for auditing purposes
CREATE TABLE AuditLogs (
    log_id VARCHAR(50) PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id VARCHAR(50), -- User who performed the action
    action_type VARCHAR(100) NOT NULL, -- e.g., 'Logged In', 'Added Student', 'Updated Grade'
    module VARCHAR(100), -- e.g., 'Authentication', 'Students', 'Payroll'
    details TEXT,
    ip_address VARCHAR(45), -- Optional: for security logging
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Backups
-- Records information about database backups
CREATE TABLE Backups (
    backup_id VARCHAR(50) PRIMARY KEY,
    backup_name VARCHAR(255) NOT NULL UNIQUE, -- e.g., 'BK20231026-001'
    backup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    size_mb DECIMAL(10, 2),
    backup_type VARCHAR(50), -- 'Full', 'Incremental'
    stored_path TEXT, -- Path to the backup file
    created_by_user_id VARCHAR(50),
    FOREIGN KEY (created_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: StudentAttendance
-- Records daily attendance for students
CREATE TABLE StudentAttendance (
    attendance_id VARCHAR(50) PRIMARY KEY,
    student_id VARCHAR(50) NOT NULL,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'Present', 'Absent', 'Leave'
    remarks TEXT,
    marked_by_user_id VARCHAR(50), -- User who marked the attendance
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (marked_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    UNIQUE (student_id, attendance_date) -- Ensure only one attendance record per student per day
);

-- Table: TeacherAttendance
-- Records daily attendance for teachers
CREATE TABLE TeacherAttendance (
    attendance_id VARCHAR(50) PRIMARY KEY,
    teacher_id VARCHAR(50) NOT NULL,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'Present', 'Absent', 'Leave'
    remarks TEXT,
    marked_by_user_id VARCHAR(50), -- User who marked the attendance
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES Teachers(teacher_id) ON DELETE CASCADE,
    FOREIGN KEY (marked_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    UNIQUE (teacher_id, attendance_date) -- Ensure only one attendance record per teacher per day
);

-- Table: Holidays
-- Stores school holidays
CREATE TABLE Holidays (
    holiday_id VARCHAR(50) PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    holiday_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: Events
-- Stores school events for the calendar
CREATE TABLE Events (
    event_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE, -- Optional, for multi-day events
    all_day BOOLEAN DEFAULT TRUE,
    description TEXT,
    event_type VARCHAR(100), -- e.g., 'Meeting', 'Sports', 'Exams'
    color_code VARCHAR(7), -- Hex color code for calendar display
    created_by_user_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: SystemSettings
-- Stores general application configuration settings
CREATE TABLE SystemSettings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT,
    description TEXT,
    last_updated_by_user_id VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (last_updated_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Roles
-- Defines different roles in the system
CREATE TABLE Roles (
    role_name VARCHAR(50) PRIMARY KEY, -- e.g., 'Admin', 'Teacher', 'Student', 'Staff'
    description TEXT
);

-- Table: Permissions
-- Defines individual permissions
CREATE TABLE Permissions (
    permission_name VARCHAR(100) PRIMARY KEY, -- e.g., 'manage_users', 'view_students', 'edit_grades'
    description TEXT
);

-- Junction Table: RolePermissions
-- Maps roles to their assigned permissions
CREATE TABLE RolePermissions (
    role_name VARCHAR(50) NOT NULL,
    permission_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (role_name, permission_name),
    FOREIGN KEY (role_name) REFERENCES Roles(role_name) ON DELETE CASCADE,
    FOREIGN KEY (permission_name) REFERENCES Permissions(permission_name) ON DELETE CASCADE
);