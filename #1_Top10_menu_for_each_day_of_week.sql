# 1번 문제
WITH 
`day_of_week` AS (
	SELECT
		menu_nm,
        dayofweek_log_tktm AS day_of_week,
        ROW_NUMBER() OVER (PARTITION BY dayofweek_log_tktm ORDER BY COUNT(*) DESC, menu_nm ASC) AS row_num
	FROM KAKAOBANK.MENU_LOG
    WHERE menu_nm NOT IN ('login', 'logout')
    GROUP BY menu_nm, dayofweek_log_tktm
)
SELECT
	CONCAT('Top', row_num, ' 메뉴') AS `구분`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=2, menu_nm, NULL)), '-') AS `월`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=3, menu_nm, NULL)), '-') AS `화`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=4, menu_nm, NULL)), '-') AS `수`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=5, menu_nm, NULL)), '-') AS `목`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=6, menu_nm, NULL)), '-') AS `금`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=7, menu_nm, NULL)), '-') AS `토`,
    IFNULL(GROUP_CONCAT(IF(day_of_week=1, menu_nm, NULL)), '-') AS `일`
FROM `day_of_week`
WHERE row_num <= 10
GROUP BY row_num
;
