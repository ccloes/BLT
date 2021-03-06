/****** Script for SelectTopNRows command from SSMS  ******/
   use LCCHPTest
   GO

 select distinct(UPPER(LabName)) from TESTAccessImport..BloodPbResults order by UPPER(LabName)


 insert into Lab (LabName)
   select distinct LabName from TESTAccessImport..BloodPbResults where labName is not null

-- clean up historic lab names
		-- Tamarac lab
 		update Lab set LabName = 'Tamarac' where Labname in ('TAMA','TAMAR')
		-- LeadCare II Analyzer
 		update Lab set LabName = 'LeadCare II' where Labname in ('LEADARE2','LEADCAE2','LEADCARA2','LEADCARE','LEADCARE2')
		 -- RMFP lab
		 update Lab set LabName = 'RMFP' where Labname in ('RMFP','RMFP LEAD','RMFP LEADVILLE','RMFPLEADVILL','RMFPLEADVILLE')
		 -- Quest Diagnostic lab
		 update Lab set LabName = 'Quest Diagnostic' where Labname in ('QUEST','Quest Diagnostic','LAB CORP')
		 -- Mayo Lab lab
		 update Lab set LabName = 'Mayo Lab' where Labname in ('Mayo Lab')
		 -- Lead Tech lab
		 update Lab set LabName = 'Lead Tech' where Labname in ('Lead Tech')
		 -- EVMC lab
		 update Lab set LabName = 'EVMC' where Labname in ('EVMC')
		-- DONE AT CLINIC
		 update Lab set LabName = 'DONE AT CLINIC' where Labname in ('DONE AT CLINIC')

-- remove tamarac dependencies
update BloodTestResults set labID = 1 where LabID in (Select LabID From Lab where LabName = 'Tamarac')
update BloodTestResults set labID = 21 where LabID in (Select LabID From Lab where LabName = 'LeadCare II')
update BloodTestResults set labID = 1253 where LabID in (Select LabID From Lab where LabName = 'Quest Diagnostic')
update BloodTestResults set labID = 1946 where LabID in (Select LabID From Lab where LabName = 'Lead Tech')
update BloodTestResults set labID = 1947 where LabID in (Select LabID From Lab where LabName = 'Mayo Lab')
update BloodTestResults set labID = 2242 where LabID in (Select LabID From Lab where LabName = 'DONE AT CLINIC')
update BloodTestResults set labID = 5076 where LabID in (Select LabID From Lab where LabName = 'EVMC')
update BloodTestResults set labID = 5302 where LabID in (Select LabID From Lab where LabName = 'RMFP')
update MediumSampleResults set labID = 1 where LabID in (Select LabID From Lab where LabName = 'Tamarac')
update MediumSampleResults set labID = 21 where LabID in (Select LabID From Lab where LabName = 'LeadCare II')
update MediumSampleResults set labID = 1253 where LabID in (Select LabID From Lab where LabName = 'Quest Diagnostic')
update MediumSampleResults set labID = 1946 where LabID in (Select LabID From Lab where LabName = 'Lead Tech')
update MediumSampleResults set labID = 1947 where LabID in (Select LabID From Lab where LabName = 'Mayo Lab')
update MediumSampleResults set labID = 2242 where LabID in (Select LabID From Lab where LabName = 'DONE AT CLINIC')
update MediumSampleResults set labID = 5076 where LabID in (Select LabID From Lab where LabName = 'EVMC')
update MediumSampleResults set labID = 5302 where LabID in (Select LabID From Lab where LabName = 'RMFP')
update LabNotes set LabID = 1253 where LabID in (Select LabID from Lab where LabName = 'Quest Diagnostic')

-- delete rows
delete from Lab where LabName = 'Tamarac' and LabID <> 1
delete from Lab where Labname = 'LeadCare II' and LabID <> 21
delete from Lab where LabName = 'Quest Diagnostic' and LabID <> 1253
delete from Lab where Labname = 'Lead Tech' and LabID <> 1946
delete from Lab where Labname = 'Mayo Lab' and LabID <> 1947
delete from Lab where Labname = 'DONE AT CLINIC' and LabID <> 2442
delete from Lab where Labname = 'EVMC' and LabID <> 5076
delete from Lab where Labname = 'RMFP' and LabID <> 5302


Select Lab.LabName,LN.* from LabNotes AS LN
JOIN Lab on LN.LabID = Lab.LabID
where LN.LabID in (Select LabID From Lab where LabName = 'Quest Diagnostic')

Select Lab.LabName,MSR.* from MediumSampleResults AS MSR
JOIN Lab on MSR.LabID = Lab.LabID
where MSR.LabID in (Select LabID From Lab where LabName = 'Tamarac')


Select Lab.LabName,BTR.LabID from BloodTestResults AS BTR
JOIN Lab on BTR.LabID = Lab.LabID
where BTR.LabID in (Select LabID From Lab where LabName = 'Tamarac')

select * from Lab order by LabID



select min(LabID),labname from lab
group by LabName
--LabID	labname
--21	LeadCare II
--5302	RMFP
--5076	EVMC
--1253	Quest Diagnostic
--1947	Mayo Lab
--1946	Lead Tech
--2442	DONE AT CLINIC
--1	Tamarac
