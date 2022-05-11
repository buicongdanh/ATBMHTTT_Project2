alter session set "_ORACLE_SCRIPT"=true;  

create user QLBV identified by QLBV;
grant all privileges to QLBV;
connect QLBV/QLBV;

CREATE TABLE QLBV.HSBA( 
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

CREATE TABLE QLBV.HSBA_DV( 
	MAHSBA		CHAR(8),
	MADV		CHAR(8),
	NGAY		DATE,
	MAKTV		CHAR(8),
	KETQUA		NVARCHAR2(200),
	PRIMARY KEY(MAHSBA, MADV, NGAY)
)

CREATE TABLE QLBV.BENHNHAN(
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
	TIENSUBENHGÐ	NVARCHAR2(100),
	DIUNGTHUOC	NVARCHAR2(100),
	MATKHAU		VARCHAR2(10),
	PRIMARY KEY(MABN)
)

CREATE TABLE QLBV.CSYT( 
	MACSYT		CHAR(8),
	TENCSYT		NVARCHAR2(50),
	DCCSYT		NVARCHAR2(100),
	SDTCSYT		CHAR(10),
	PRIMARY KEY(MACSYT)
)

CREATE TABLE QLBV.NHANVIEN( 
	MANV		CHAR(8),
	HOTEN		NVARCHAR2(50),
	PHAI		NVARCHAR2(3),
	NGAYSINH	DATE,
	CMND		CHAR(12),
	QUEQUAN		NVARCHAR2(50),
	SOÐT		CHAR(10),
	CSYT		CHAR(8),
	VAITRO		NVARCHAR2(30),
	CHUYENKHOA	NVARCHAR2(20),
	MATKHAU		VARCHAR2(10),
	PRIMARY KEY(MANV)
)

ALTER TABLE QLBV.NHANVIEN ADD CONSTRAINT FK_NHANVIEN_CSYT
FOREIGN KEY (CSYT) REFERENCES QLBV.CSYT(MACSYT);

ALTER TABLE QLBV.BENHNHAN ADD CONSTRAINT FK_BENHNHAN_CSYT
FOREIGN KEY (MACSYT) REFERENCES QLBV.CSYT(MACSYT);

ALTER TABLE QLBV.HSBA ADD CONSTRAINT FK_HSBA_NHANVIEN
FOREIGN KEY (MABS) REFERENCES QLBV.NHANVIEN(MANV);

ALTER TABLE QLBV.HSBA ADD CONSTRAINT FK_HSBA_CSYT
FOREIGN KEY (MACSYT) REFERENCES QLBV.CSYT(MACSYT);

--PROC dung de cap user/password cho cac benh nhan chua co tai khoan
CREATE OR REPLACE PROCEDURE usp_Create_BenhNhan_Acc
AS
	CURSOR CUR IS(	SELECT MABN
					FROM QLBV.BENHNHAN
					WHERE MABN NOT IN (SELECT USERNAME FROM ALL_USERS));
	strSQL 	VARCHAR(2000);
	ck_User int;
	Usr 	CHAR(8);
    
BEGIN
	OPEN CUR;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
	EXECUTE IMMEDIATE (strSQL);
	LOOP
		FETCH CUR INTO Usr;
		EXIT WHEN CUR%NOTFOUND;
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Usr;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--PROC dung de cap user/password cho cac nhanvien chua co tai khoan
CREATE OR REPLACE PROCEDURE usp_Create_NhanVien_Acc
AS
	CURSOR CUR IS(	SELECT MANV
					FROM QLBV.NHANVIEN
					WHERE MANV NOT IN (SELECT USERNAME FROM ALL_USERS));
	strSQL 	VARCHAR(2000);
	ck_User int;
	Usr 	CHAR(8);
    
BEGIN
	OPEN CUR;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
	EXECUTE IMMEDIATE (strSQL);
	LOOP
		FETCH CUR INTO Usr;
		EXIT WHEN CUR%NOTFOUND;
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Usr;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--Procedure tao user nhan vien + grant connection
CREATE OR REPLACE PROCEDURE usp_Create_UsrNhanVien (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
	l_count	NUMBER;
BEGIN
	SELECT COUNT(*) into l_count from QLBV.NHANVIEN where MANV = Usr;
	IF l_count = 0 then
	BEGIN
		strSQL := 'INSERT INTO QLBV.NHANVIEN (MANV, MATKHAU) VALUES (:1, :2)';
		EXECUTE IMMEDIATE (strSQL) USING Usr, Psw;
        strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Psw;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'GRANT CREATE SESSION TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
		strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
		EXECUTE IMMEDIATE (strSQL);
	END;
END IF;
END;

--Procedure tao user + grant connection
CREATE OR REPLACE PROCEDURE usp_Create_UsrBenhNhan (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
    l_count NUMBER;
BEGIN
        SELECT COUNT(*) into l_count from QLBV.NHANVIEN where MANV = Usr;
        IF l_count = 0 then
        BEGIN
            strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
            EXECUTE IMMEDIATE (strSQL);
            strSQL := 'INSERT INTO QLBV.BENHNHAN (MANV, MATKHAU) VALUES (:1, :2)';
            EXECUTE IMMEDIATE (strSQL) USING Usr, Psw;
            strSQL := 'CREATE USER ' ||Usr|| ' IDENTIFIED BY '||Psw;
            EXECUTE IMMEDIATE (strSQL);
            strSQL := 'GRANT CREATE SESSION TO ' || USR;
            EXECUTE IMMEDIATE (strSQL);
            strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
            EXECUTE IMMEDIATE (strSQL);
        END;
        END IF;
END;

--HAM CHINH SACH
-- Tra ve thong tin
CREATE OR REPLACE FUNCTION sec_function(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR2
AS
	usr VARCHAR2(100);
BEGIN
    usr := SYS_CONTEXT('USERENV', 'SESSION_USER');
    return 'MANV = ''' || usr || '''';
END;

-- NULL Policy
CREATE OR REPLACE FUNCTION no_records(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR
AS
	usr VARCHAR2(100);
BEGIN
    usr := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF(usr = 'SYS' OR usr = 'DBA') THEN
        RETURN '';
    ELSE
        return '1=0';
    END IF;
End;

--POLICY
--1. NhanVien chi duoc xem va cap nhat thong tin cua ban than
BEGIN 
dbms_rls.add_policy (
    object_schema => 'QLBV',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy1',
	policy_function => 'sec_function',
	statement_types => 'SELECT, UPDATE');
END;

 --2. BenhNhan chi duoc xem va cap nhat thong tin cua ban than
BEGIN
dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'BENHNHAN',
	policy_name => 'my_policy2',
	policy_function => 'sec_function',
	statement_types => 'SELECT, UPDATE');
END;

GRANT SELECT ON QLBV.NHANVIEN TO NV000001

--3. NhanVien khong duoc cap nhat truong ma cua ho
BEGIN
dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy3',
	policy_function => 'sec_function',
	statement_types => 'UPDATE, DELETE',
	sec_relevant_cols => 'MaNV');
END;

--4. BENHNHAN khong duoc cap nhat truong ma cua ho
BEGIN
dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'BENHNHAN',
	policy_name => 'my_policy4',
	policy_function => 'sec_function',
	statement_types => 'UPDATE, DELETE',
	sec_relevant_cols => 'MaBN');
END;

--TC2
--Procedure tao user ThanhTra + grant connection
CREATE OR REPLACE PROCEDURE usp_Update_UsrThanhTra (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
BEGIN
        strSQL := 'UPDATE VAITRO=''ThanhTra'' where MANV=Usr';
        EXECUTE IMMEDIATE (strSQL);
END;
--Function
CREATE OR REPLACE PROCEDURE SELECT_ALL(Usr in CHAR)
as
    strSQL varchar(2000);
begin
    strSQL := 'SELECT * FROM HSBA, HSBA_DV, BENHNHAN, NHANVIEN, CSYT';
    EXECUTE IMMEDIATE (strSQL);
END;

--ThanhTra duoc xem tren tat ca quan he
execute dbms_rls.add_policy(
	object_schema => 'BCDANH',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy5',
	policy_function => 'SELECT_ALL',
	statement_types => 'SELECT'
);
-- Thanh tra khong co quyen them xoa sua
execute dbms_rls.add_policy(
	object_schema => 'BCDANH',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy6',
	policy_function => 'SELECT_ALL',
	statement_types => 'UPDATE, INSERT, DELETE'
);

--Procedure tao user Nhan vien CSYT + grant connection
CREATE OR REPLACE PROCEDURE usp_Create_UsrNhanVienCSYT (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
BEGIN
		strSQL := 'UPDATE VAITRO=''ThanhTra'' where MANV=Usr';
        EXECUTE IMMEDIATE (strSQL);
END;

--TC3
--sec_fucntion2
Variable datetest number;
BEGIN
   Select to_char(sysdate,'DD') into :datetest
from dual;
END;

print datetest;

CREATE OR REPLACE FUNCTION sec_function2(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR2
AS
	usr VARCHAR2(100);
    datetest number;
BEGIN
    if(datetest>=5) then 
        usr := SYS_CONTEXT('USERENV', 'SESSION_USER');
        return 'MANV = ''' || usr || '''';      
    end if;    
End;

--Nhan vien CSYT duoc them xoa dong tren HSBA 
BEGIN
     dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'HSBA',
	policy_name => 'my_policy7',
	policy_function => 'sec_function',
	statement_types => 'INSERT, DELETE'
);
--Nhan vien CSYT duoc them xoa dong tren HSBA_DV
BEGIN
     dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'HSBA_DV',
	policy_name => 'my_policy8',
	policy_function => 'sec_function',
	statement_types => 'INSERT, DELETE'
);