# 3번 문제
WITH
`demo` AS (
	SELECT
		usr_no,
        (YEAR('20200626') - YEAR(SUBSTR(rsdt_no, 1, 8))) - (DATE_FORMAT(SUBSTR(rsdt_no, 1, 8), '%m%d') > DATE_FORMAT('20200626', '%m%d')) AS age,
        IF(SUBSTR(rsdt_no, 1, 4) >= '2000', IF(SUBSTR(rsdt_no, 9, 1) = '3', '남', '여'), IF(SUBSTR(rsdt_no, 9, 1) = '1', '남', '여')) AS gender
	FROM (
		SELECT
			usr_no,
            IF(SUBSTR(rsdt_no, 1, 2) BETWEEN '00' AND '20', CONCAT('20', rsdt_no), CONCAT('19', rsdt_no)) AS rsdt_no
		FROM (
			SELECT
				usr_no, 
                rsdt_no,
                ROW_NUMBER() OVER (PARTITION BY usr_no ORDER BY log_tktm DESC) AS row_num
			FROM KAKAOBANK.USR_INFO_CHG_LOG
            WHERE rsdt_no != ''
        ) base
        WHERE row_num <= 1
    ) usr
),
`loc` AS (
	SELECT
		usr_no,
        loc_nm,
        (
			SELECT loc_nm FROM KAKAOBANK.USR_INFO_CHG_LOG prev_t
            WHERE curr_t.log_tktm > prev_t.log_tktm AND curr_t.usr_no = prev_t.usr_no
            ORDER BY log_tktm DESC LIMIT 1
		) AS prev_loc_nm
	FROM (
		SELECT
			usr_no,
            loc_nm,
            log_tktm,
            ROW_NUMBER() OVER (PARTITION BY usr_no ORDER BY log_tktm DESC) AS row_num
		FROM KAKAOBANK.USR_INFO_CHG_LOG
        WHERE loc_nm != ''
    ) curr_t
    WHERE row_num <= 1
),
`mcco` AS (
	SELECT
		usr_no,
        mcco_nm
	FROM (
		SELECT
			usr_no,
            mcco_nm,
            ROW_NUMBER() OVER (PARTITION BY usr_no ORDER BY log_tktm DESC) AS row_num
		FROM KAKAOBANK.USR_INFO_CHG_LOG
        WHERE mcco_nm != ''
    ) mcco
    WHERE row_num <= 1
), 
`reg` AS (
	SELECT
		usr_no,
        SUBSTR(MIN(log_tktm), 1, 8) AS REG_DT
	FROM KAKAOBANK.USR_INFO_CHG_LOG
    GROUP BY usr_no
),
`menu` AS (
	SELECT
		usr_no,
        GROUP_CONCAT(IF(visit_rank=1, menu_nm, NULL)) AS most_visit_menu,
        GROUP_CONCAT(IF(time_rank=1, menu_nm, NULL)) AS latest_visit_menu
	FROM (
		SELECT
			usr_no,
            menu_nm,
            ROW_NUMBER() OVER (PARTITION BY usr_no ORDER BY COUNT(*) DESC, menu_nm ASC) AS visit_rank,
            ROW_NUMBER() OVER (PARTITION BY usr_no ORDER BY log_tktm DESC) AS time_rank
		FROM KAKAOBANK.MENU_LOG
        WHERE menu_nm NOT IN ('login','logout')
        GROUP BY usr_no, menu_nm
    ) menu
    WHERE visit_rank = 1 OR time_rank = 1
    GROUP BY usr_no
) 
SELECT
	a.usr_no AS `사용자번호`,
    IFNULL(b.gender, '-') AS `성별`,
    IFNULL(b.age, '-') AS `나이`,
    IFNULL(c.loc_nm, '-') AS `지역명`,
    IF( c.prev_loc_nm IS NULL OR c.prev_loc_nm = '', '-', c.prev_loc_nm) AS `이전 지역명`,
    IFNULL(d.mcco_nm, '-') AS `이동통신사명`,
    a.reg_dt AS `가입일`,
    IFNULL(e.most_visit_menu, '-') AS `최빈메뉴`,
    IFNULL(e.latest_visit_menu, '-') AS `최근메뉴`
FROM `reg` a
	LEFT OUTER JOIN `demo` b ON (a.usr_no = b.usr_no)
	LEFT OUTER JOIN `loc` c ON (a.usr_no = c.usr_no)
	LEFT OUTER JOIN `mcco` d ON (a.usr_no = d.usr_no)
	LEFT OUTER JOIN `menu` e ON (a.usr_no = e.usr_no)
ORDER BY `사용자번호`
;