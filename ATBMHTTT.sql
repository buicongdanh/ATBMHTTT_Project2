alter session set "_ORACLE_SCRIPT"=true;  
/*---DANH SACH CAC USER TAO DE THUC HIEN DEMO*/
--1. QLBV
create user QLBV identified by QLBV;
grant all privileges to QLBV;
connect QLBV/QLBV;

--2. BN
create user BN000001 identified by BN000001;
GRANT CREATE SESSION TO BN000001
CREATE ROLE BENH_NHAN
SET ROLE BENH_NHAN
GRANT BENH_NHAN TO BN000001
GRANT SELECT, UPDATE ON QLBV.BENHNHAN TO BENH_NHAN

--3. ThanhTra
create user NV000003 identified by NV000003;
GRANT CREATE SESSION TO NV000003
CREATE ROLE THANH_TRA
SET ROLE THANH_TRA
GRANT THANH_TRA TO NV000003
GRANT SELECT TO THANH_TRA

--4. Y/Bac si
create user NV000056 identified by NV000056;
GRANT CREATE SESSION TO NV000056
CREATE ROLE BAC_SI
SET ROLE BAC_SI
GRANT BAC_SI TO NV000056
GRANT SELECT ON HSBA TO BAC_SI
GRANT SELECT ON HSBA_DV TO BAC_SI

--5. NV CSYT
create user NV000006 identified by NV000006;
GRANT CREATE SESSION TO NV000006
CREATE ROLE NV_CSYT
SET ROLE NV_CSYT
GRANT NV_CSYT TO NV000006
GRANT INSERT, UPDATE ON HSBA TO NV_CSYT
GRANT INSERT, UPDATE ON HSBA_DV TO NV_CSYT

--TAO BANG
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

create table qlbv.khoa 
(
    makhoa char(8) primary key, 
    tenkhoa nvarchar2(30)
);

create table qlbv.thongbao 
(
    MATB char(8) primary key, 
    noidung varchar2(4000),
    ngaygio date, 
    diadiem varchar2(200)
);

--KHOA NGOAI
ALTER TABLE QLBV.NHANVIEN ADD CONSTRAINT FK_NHANVIEN_CSYT
FOREIGN KEY (CSYT) REFERENCES QLBV.CSYT(MACSYT);

ALTER TABLE QLBV.BENHNHAN ADD CONSTRAINT FK_BENHNHAN_CSYT
FOREIGN KEY (MACSYT) REFERENCES QLBV.CSYT(MACSYT);

ALTER TABLE QLBV.HSBA ADD CONSTRAINT FK_HSBA_NHANVIEN
FOREIGN KEY (MABS) REFERENCES QLBV.NHANVIEN(MANV);

ALTER TABLE QLBV.HSBA ADD CONSTRAINT FK_HSBA_CSYT
FOREIGN KEY (MACSYT) REFERENCES QLBV.CSYT(MACSYT);

alter table qlbv.hsba
add constraint fk_kh_hs foreign key (makhoa) references qlbv.khoa (makhoa);
alter table qlbv.nhanvien 
add constraint fk_kh_nv  foreign key (chuyenkhoa) references qlbv.khoa (makhoa);

CREATE ROLE BENH_NHAN
SET ROLE BENH_NHAN

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
		strSQL := 'GRANT BENH_NHAN TO ' || USR;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--PROC dung de cap user/password cho cac nhan vien chua co tai khoan
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
CREATE OR REPLACE PROCEDURE usp_Create_UsrNhanVien (Usr IN CHAR, Psw IN CHAR, VaiTro IN CHAR)
AS
	strSQL 	VARCHAR(2000);
	l_count	NUMBER;
BEGIN
	SELECT COUNT(*) into l_count from QLBV.NHANVIEN where MANV = Usr;
	IF l_count = 0 then
	BEGIN
		strSQL := 'INSERT INTO QLBV.NHANVIEN (MANV, MATKHAU, VAITRO) VALUES (:1, :2, :3)';
		EXECUTE IMMEDIATE (strSQL) USING Usr, Psw, VaiTro;
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

--Procedure tao BENHNHAN + grant connection
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

--#TC6
--1. NhanVien chi duoc xem va cap nhat thong tin cua ban than
BEGIN 
dbms_rls.add_policy (
    object_schema => 'QLBV',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy1',
	policy_function => 'sec_function',
	statement_types => 'SELECT, UPDATE');
END;

--2. NhanVien khong duoc cap nhat truong ma cua ho
BEGIN
dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'NHANVIEN',
	policy_name => 'my_policy3',
	policy_function => 'sec_function',
	statement_types => 'UPDATE, DELETE',
	sec_relevant_cols => 'MaNV');
END;

--BENHNHAN
CREATE OR REPLACE PROCEDURE usp_Add_Benh_Nhan
AS
	CURSOR CUR IS(	SELECT MANV
					FROM QLBV.NHANVIEN
					WHERE VAITRO = 'Benh nhan');
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
		strSQL := 'GRANT BENH_NHAN TO ' ||Usr||;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--GRANT CAC QUYEN SELECT, UPDATE LEN BENHNHAN
GRANT SELECT, UPDATE ON BENHNHAN TO BENH_NHAN

CREATE OR REPLACE FUNCTION sec_function_2(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR2
AS
	usr VARCHAR2(100);
BEGIN
    usr := SYS_CONTEXT('USERENV', 'SESSION_USER');
    return 'MABN = ''' || usr || '''';
END;

--1. BenhNhan chi duoc xem va cap nhat thong tin cua ban than
BEGIN
dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'BENHNHAN',
	policy_name => 'my_policy2',
	policy_function => 'sec_function_2',
	statement_types => 'SELECT, UPDATE');
END;

--2. BENHNHAN khong duoc cap nhat truong ma cua ho
BEGIN
dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'BENHNHAN',
	policy_name => 'my_policy4',
	policy_function => 'sec_function_2',
	statement_types => 'UPDATE, DELETE',
	sec_relevant_cols => 'MaBN');
END;

--THANH TRA
CREATE ROLE THANH_TRA
SET ROLE THANH_TRA

CREATE OR REPLACE PROCEDURE usp_Add_Thanh_Tra
AS
	CURSOR CUR IS(	SELECT MANV
					FROM QLBV.NHANVIEN
					WHERE VAITRO = 'Thanh Tra');
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
		strSQL := 'GRANT THANH_TRA TO ' ||Usr;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--Thanh tra duoc xem tren tat ca quan he
--Nhung khong duoc them, xoa, sua
GRANT SELECT TO THANH_TRA

/*
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
);*/


/*--Procedure tao user Nhan vien CSYT + grant connection
CREATE OR REPLACE PROCEDURE usp_Create_UsrNhanVienCSYT (Usr IN CHAR, Psw IN CHAR)
AS
	strSQL 	VARCHAR(2000);
BEGIN
		strSQL := 'UPDATE VAITRO=''ThanhTra'' where MANV=Usr';
        EXECUTE IMMEDIATE (strSQL);
END;*/
--TC#3
--TAO ROLE
CREATE ROLE NV_CSYT
SET ROLE NV_CSYT

--THEM CAC NHANVIEN CO VAI TRO LA NV_CSYT
CREATE OR REPLACE PROCEDURE usp_add_NhanVien_CSYT
AS
	CURSOR CUR IS(	SELECT MANV
					FROM QLBV.NHANVIEN
					WHERE VAITRO = 'Co so y te');
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
		strSQL := 'GRANT NV_CSYT TO ' ||Usr||;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--NV CSYT duoc them, xoa dong tren HSBA + HSBA_DV
GRANT INSERT, DELETE ON HSBA TO NV_CSYT
GRANT INSERT, DELETE ON HSBA_DV TO NV_CSYT

--Ham chinh sach
Variable datetest number;
BEGIN
   Select to_char(sysdate,'DD') into :datetest from dual;
END;

print datetest;

CREATE OR REPLACE FUNCTION between_5_27(p_schema VARCHAR2, p_obj VARCHAR2)
RETURN VARCHAR2
AS
	usr VARCHAR2(100);
    datetest number;
BEGIN
	Select to_char(sysdate,'DD') into :datetest from dual;
    if(datetest < 5 OR datetest > 27) then 
        return '1=0';      
	else
		return '';
    end if;    
End;

--Nhan vien CSYT duoc them xoa dong tren HSBA tu ngay 5 den ngay 27 hang thang
BEGIN
     dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'HSBA',
	policy_name => 'my_policy7',
	policy_function => 'between_5_27',
	statement_types => 'INSERT, DELETE'
);

--Nhan vien CSYT duoc them xoa dong tren HSBA_DV tu ngay 5 den ngay 27 hang thang
BEGIN
     dbms_rls.add_policy(
	object_schema => 'QLBV',
	object_name => 'HSBA_DV',
	policy_name => 'my_policy8',
	policy_function => 'between_5_27',
	statement_types => 'INSERT, DELETE'
);

--#TC4
--Tao role bac si
CREATE ROLE BAC_SI
SET ROLE BAC_SI

--Them cac nhan vien la bac si vao role
CREATE OR REPLACE PROCEDURE usp_add_Bac_Si
AS
	CURSOR CUR IS(	SELECT MANV
					FROM QLBV.NHANVIEN
					WHERE VAITRO = 'Y si/Bac si');
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
		strSQL := 'GRANT BAC_SI TO ' ||Usr;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;

--Y bac si duwoc phep xem cac ho so benh an cuar minh chua tri
create view qlbv.CS4_1 as select * from qlbv.hsba;
GRANT SELECT ON qlbv.CS4_1 to BAC_SI

create or replace function qlbv.TC4_1 
(p_schema in varchar2, p_object in varchar2)
return varchar2
as 
user_ varchar2(100);
begin
    user_ := sys_context('userenv','session_user');
    return 'mabs = '''|| user_ ||'''';       
end; 

grant select on qlbv.CS4_1 to NV000090;

begin dbms_rls.add_policy (object_schema => 'QLBV',
                            object_name => 'HSBA',
                            policy_name => 'policy4_1',
                            --function_schema => 'QLBV',
                            policy_function => 'TC4_1',
                            statement_types => 'select');
end;

--Y bac si duwoc phep xem cac hsba_dv ma minh da chua tri 
create or replace function qlbv.TC4_2 
(p_object in varchar2, p_schema in varchar2)
return varchar2
as 
user_ varchar2(100);
mahs_ varchar2(200);
begin
    user_ := sys_context('userenv','session_user');
    mahs_ := '(select mahs from qlbv.hsba where mabs = ( select sys_context(''userenv'',''session_user'') from dual))';
    return 'mahs = ' || CHR(39)||mahs_||CHR(39);
end;

grant select on qlbv.hsba_dv to NV000090;

begin dbms_rls.add_policy (object_schema => 'QLBV',
                            object_name => 'HSBA',
                            policy_name => 'policy4_2',
                            function_schema => 'QLBV',
                            policy_function => 'TC4_2' );
end;

--#TC5
CREATE ROLE NGHIEN_CUU
SET ROLE NGHIEN_CUU

CREATE OR REPLACE PROCEDURE usp_add_Nghien_Cuu
AS
	CURSOR CUR IS(	SELECT MANV
					FROM QLBV.NHANVIEN
					WHERE VAITRO = 'Nghien Cuu');
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
		strSQL := 'GRANT NGHIEN_CUU TO ' ||Usr;
		EXECUTE IMMEDIATE (strSQL);
	END LOOP;
	strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE';
    EXECUTE IMMEDIATE (strSQL);
END;
--Nhan vien nghien duoc phep xem cac ho so benh an o co so y te do co cung chuyen khoa cua nhan vien nghien cuu
create or replace function qlbv.TC5_1 (p_object in varchar2, p_schema in varchar2)
return varchar2
as 
user_ varchar2(100);
macsyt_ varchar2(200); 
makhoa_ varchar2(100);
result_ varchar2(200);
begin
    user_ := sys_context('userenv','session_user');
    macsyt_ := '(select macsyt from qlbv.nhanvien where manv = ( select sys_context(''userenv'',''session_user'') from dual))';
    makhoa_ := '(select chuyenkhoa from qlbv.nhanvien where manv = (select sys_context(''userenv'',''session_user'') from dual))'; 
    result_ := 'makhoa = ' || CHR(39) || makhoa_ || CHR(39) || ' and macsyt = ' || CHR(39) || macsyt_ || CHR(39); 
    return result_; --|| ' and macsyt = ' ||CHR(39)||macsyt_||CHR(39);
    --return 'macsyt = ' || CHR(39)||macsyt_||CHR(39);  
end;

create view qlbv.CS5_1 as select * from qlbv.hsba;
GRANT SELECT ON qlbv.CS5_1 TO NGHIEN_CUU

begin dbms_rls.add_policy (object_schema => 'QLBV',
                            object_name => 'CS5_1',
                            policy_name => 'policy5_1',
                            policy_function => 'TC5_1' );
end; 

--Nhan vien nghien cuu duoc phep xem cac hsba_dv co cung co so y te va cung chuyen khoa 
create or replace function TC5_2 (p_schema in varchar2, p_object in varchar2)
return varchar2
as 
mahs_ varchar2(100);
manv_ varchar2(100);
begin
    manv_ := sys_context('userenv','session_user');
    mahs_ := '(select mahs from hsba where makhoa = (select chuyenkhoa from nhanvien where manv = ' ||manv_|| ') and macsyt = (select macsyt from nhanvien where manv = ' ||manv_|| '))';
    return 'mahs = ' || CHR(39)||mahs_||CHR(39);
end;

create view qlbv.CS5_2 as select * from qlbv.hsba_dv;
begin dbms_rls.add_policy (object_schema => 'QLBV',
                            object_name => 'CS5_2',
                            policy_name => 'policy5_2',
                            policy_function => 'TC5_2');
end;

GRANT SELECT ON qlbv.CS5_2 TO NGHIEN_CUU

--#TC7
--cai dat cac level va nhan trong OLS 
exec sa_sysdba.create_policy ('ACCESS_NHANVIEN','OLS_NHANVIEN');
grant access_nhanvien_dba to QLBV;

GRANT EXECUTE ON SA_COMPONENTS TO QLBV;

GRANT EXECUTE ON SA_LABEL_ADMIN TO QLBV;

GRANT EXECUTE ON SA_POLICY_ADMIN TO QLBV;

GRANT EXECUTE ON SA_USER_ADMIN TO QLBV;

GRANT EXECUTE ON CHAR_TO_LABEL TO QLBV;

EXEC SA_COMPONENTS.CREATE_LEVEL('ACCESS_NHANVIEN',
8000,
'GDSO',
'GIAM DOC SO');

EXEC SA_COMPONENTS.CREATE_LEVEL('ACCESS_NHANVIEN',
7000,
'GDCSYT', 
'GIAM DOC CO SO Y TE');

EXEC SA_COMPONENTS.CREATE_LEVEL('ACCESS_NHANVIEN',
6000,
'BS', 
'Y BAC SI');

EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_NHANVIEN',
1000,
'NGOAITRU',
'DIEU TRI NGOAI TRU');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_NHANVIEN',
2000,
'NOI TRU',
'DIEU TRI NOI TRU');
EXEC SA_COMPONENTS.CREATE_COMPARTMENT('ACCESS_NHANVIEN',
3000,
'CS',
'DIEU TRI CHUYEN SAU');

EXEC SA_COMPONENTS.CREATE_GROUP('ACCESS_NHANVIEN',

1,
'TRUNGTAM',
'TRUNG TAM',
NULL);
EXEC SA_COMPONENTS.CREATE_GROUP('ACCESS_NHANVIEN',
2,
'CANTRUNGTAM',
'CAN TRUNG TAM',
'NULL');
EXEC SA_COMPONENTS.CREATE_GROUP('ACCESS_NHANVIEN',
3,
'NGOAI THANH',
'NGOAI THANH',
'NULL');

EXEC SA_LABEL_ADMIN.CREATE_LABEL ('ACCESS_NHANVIEN',
300,
,'BS:CS:TRUNGTAM');
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('ACCESS_NHANVIEN',
400,
,'GDCSYT: NGOAITHANH');
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('ACCESS_NHANVIEN',
500,
,'GDSO:CANTRUNGTAM');

--audit
AUDIT UPDATE, INSERT, DELETE
ON QLBV.NHANVIEN
WHENEVER SUCCESSFUL; 

-- Query view DBA_AUDIT_TRAIL:
select username, owner, obj_name,
       action_name, sql_text from dba_audit_trail;
       
BEGIN
DBMS_FGA.add_policy (
    object_schema => 'QLBV',
    object_name => 'NHANVIEN',
    policy_name => 'Policy_1',
    audit_condition => 'NULL',
    statement_types => 'SELECT, UPDATE');
END;

BEGIN
DBMS_FGA.drop_policy (
    object_schema => 'QLBV',
    object_name => 'NHANVIEN',
    policy_name => 'Policy_1');
END;

SELECT * FROM DBA_FGA_AUDIT_TRAIL;
