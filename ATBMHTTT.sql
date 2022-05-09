CREATE TABLE HSBA( 
	MAHSBA		CHAR(8),
	MABN		CHAR(8),
	NGAY		DATE,
	CHANDOAN	NVARCHAR2(200),
	MABS		CHAR(8),
	MAKHOA		CHAR(8),
	MACSYT		CHAR(8),
	KETLUAN		NVARCHAR2(200),
	PRIMARY KEY(MAHSBA)
)

CREATE TABLE HSBA_DV( 
	MAHSBA		CHAR(8),
	MADV		CHAR(8),
	NGAY		DATE,
	MAKTV		CHAR(8),
	KETQUA		NVARCHAR2(200),
	PRIMARY KEY(MAHSBA, MADV, NGAY)
)

CREATE TABLE BENHNHAN(
	MABN		CHAR(8),
	MACSYT		CHAR(8),
	TENBN		NVARCHAR2(50),
	CMND		CHAR(12),
	NGAYSINH	DATE,
	SONHA		NVARCHAR2(30),	
	TENDUONG	NVARCHAR2(50),
	QUANHUYEN	NVARCHAR2(20),
	TINHTP		NVARCHAR2(50),
	TIENSUBENH	NVARCHAR2(100),
	TIENSUBENHG�	NVARCHAR2(100),
	DIUNGTHUOC	NVARCHAR2(100),
	MATKHAU		VARCHAR2(10),
	PRIMARY KEY(MABN)
)

CREATE TABLE CSYT( 
	MACSYT		CHAR(8),
	TENCSYT		NVARCHAR2(50),
	DCCSYT		NVARCHAR2(100),
	SDTCSYT		CHAR2(10),
	PRIMARY KEY(MACSYT)
)

CREATE TABLE NHANVIEN( 
	MANV		CHAR(8),
	HOTEN		NVARCHAR2(50),
	PHAI		BIT,
	NGAYSINH	DATE,
	CMND		CHAR(12),
	QUEQUAN		NVARCHAR(50),
	SO�T		CHAR(10),
	CSYT		CHAR(8),
	VAITRO		NVARCHAR(30),
	CHUYENKHOA	NVARCHAR(20),
	MATKHAU		VARCHAR2(10),
	PRIMARY KEY(MANV)
)

ALTER TABLE NHANVIEN ADD CONSTRAINT FK_NHANVIEN_CSYT
FOREIGN KEY (CSYT) REFERENCES CSYT(MACSYT);

ALTER TABLE BENHNHAN ADD CONSTRAINT FK_BENHNHAN_CSYT
FOREIGN KEY (CSYT) REFERENCES CSYT(MACSYT);

ALTER TABLE NHANVIEN ADD CONSTRAINT FK_NHANVIEN_USERNAME
FOREIGN KEY (USERNAME) REFERENCES ALL_USERS(USERNAME);

ALTER TABLE BENHNHAN ADD CONSTRAINT FK_BENHNHAN_USERNAME
FOREIGN KEY (USERNAME) REFERENCES ALL_USERS(USERNAME);

ALTER TABLE HSBA ADD CONSTRAINT FK_HSBA_NHANVIEN
FOREIGN KEY (MABS) REFERENCES NHANVIEN(MANV);

ALTER TABLE HSBA ADD CONSTRAINT FK_HSBA_CSYT
FOREIGN KEY (MACSYT) REFERENCES CSYT(MACSYT);

--PROC dung de cap user/password cho cac benh nhan chua co tai khoan
CREATE OR REPLACE PROCEDURE usp_Create_BenhNhan_Acc
AS
	CURSOR CUR IS(	SELECT MABN
					FROM BENHNHANH
					WHERE MABN NOT IN (SELECT USERNAME FROM ALL_USERS));
	strSQL 	VARCHAR(2000);
	ck_User int;
	Usr 	CHAR(8)
BEGIN
	OPEN CUR;
	strSQL = 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
	EXECUTE IMMEDIATE (strSQL);
	LOOP
		FETCH CUR TO Usr;
		EXIT WHEN CUR%NOTFOUND;
		
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Usr;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL = ' '
	strSQL = 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
END;

--PROC dung de cap user/password cho cac nhanvien chua co tai khoan
CREATE OR REPLACE PROCEDURE usp_Create_NhanVien_Acc
AS
	CURSOR CUR IS(	SELECT MANV
					FROM NHANVIEN
					WHERE MANV NOT IN (SELECT USERNAME FROM ALL_USERS));
	strSQL 	VARCHAR(2000);
	ck_User int;
	Usr 	CHAR(8)
BEGIN
	OPEN CUR;
	strSQL = 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
	EXECUTE IMMEDIATE (strSQL);
	LOOP
		FETCH CUR TO Usr;
		EXIT WHEN CUR%NOTFOUND;
		
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Usr;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL = ' '
	strSQL = 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
END;

--Procedure tao user nhan vien + grant connection
CREATE OR REPLACE PROCEDURE usp_Create_UsrNhanVien (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
BEGIN
		strSQL := 'INSERT INTO NHANVIEN (MANV, MATKHAU) VALUES (:1, :2)';
		EXECUTE IMMEDIATE (strSQL) USING Usr, Psw;
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Psw;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
		EXECUTE IMMEDIATE (strSQL);
exception
WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Duplicate val');
    RAISE;
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in ADD_USER : ' || SQLCODE || ' : ' || SQLERRM);
    RAISE;
END;

--Procedure tao user + grant connection
CREATE OR REPLACE PROCEDURE usp_Create_UsrBenhNhan (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
BEGIN
		strSQL := 'INSERT INTO BENHNHAN (MANV, MATKHAU) VALUES (:1, :2)';
		EXECUTE IMMEDIATE (strSQL) USING Usr, Psw;
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Psw;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
		EXECUTE IMMEDIATE (strSQL);
exception
WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Duplicate val');
    RAISE;
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in ADD_USER : ' || SQLCODE || ' : ' || SQLERRM);
    RAISE;
END;


--HAM CHINH SACH
-- Tra ve thong tin
CREATE FUNCTION sec_function(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR2
AS
	user VARCHAR2(100);
BEGIN
	if(SYS_CONTEXT('usernv', 'ISDBA')) then
		RETURN '';
	else
		user:=SYS_CONTEXT('userenv', 'SESSION_USER');
		RETURN 'username = ' || user;
	end if;
End;

-- NULL Policy
CREATE FUNCTION no_records(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR2
BEGIN
	return '1=0';
End;

--POLICY
--1. NhanVien chi duoc xem va cap nhat thong tin cua ban than
execute dbms_rls.add_policy(
	object_schema => 'BCDANH',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy1',
	policy_function => 'sec_function',
	statement_types => 'SELECT, UPDATE');
);
 
 --2. BenhNhan chi duoc xem va cap nhat thong tin cua ban than
execute dbms_rls.add_policy(
	object_schema => 'BCDANH',
	object_name => 'BENHNHAN',
	policy_name => 'my_policy2',
	policy_function => 'sec_function',
	statement_types => 'SELECT, UPDATE');
);

--3. NhanVien khong duoc cap nhat truong ma cua ho
execute dbms_rls.add_policy(
	object_schema => 'BCDANH',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy3',
	policy_function => 'no_records',
	statement_types => 'UPDATE',
	sec_relevant_cols => 'MaNV');
);

--4. BENHNHAN khong duoc cap nhat truong ma cua ho
execute dbms_rls.add_policy(
	object_schema => 'BCDANH',
	object_name => 'BENHNHAN',
	policy_name => 'my_policy4',
	policy_function => 'no_records',
	statement_types => 'UPDATE',
	sec_relevant_cols => 'MaBN');
);
