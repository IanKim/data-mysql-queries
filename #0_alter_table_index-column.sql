ALTER TABLE KAKAOBANK.MENU_LOG ADD COLUMN `dayofweek_log_tktm` TINYINT GENERATED ALWAYS AS (DAYOFWEEK(log_tktm)) VIRTUAL;
ALTER TABLE KAKAOBANK.MENU_LOG ADD INDEX `menu_log_idx-01` (`menu_nm`, `dayofweek_log_tktm`);
ALTER TABLE KAKAOBANK.MENU_LOG ADD INDEX `menu_log_idx-02` (`usr_no`, `menu_nm`);
ALTER TABLE KAKAOBANK.USR_INFO_CHG_LOG ADD INDEX `usr_info_chg_log_idx-01` (`rsdt_no`);
ALTER TABLE KAKAOBANK.USR_INFO_CHG_LOG ADD INDEX `usr_info_chg_log_idx-02` (`usr_no`, `log_tktm`);
ALTER TABLE KAKAOBANK.USR_INFO_CHG_LOG ADD INDEX `usr_info_chg_log_idx-03` (`loc_nm`);
ALTER TABLE KAKAOBANK.USR_INFO_CHG_LOG ADD INDEX `usr_info_chg_log_idx-04` (`mcco_nm`);
