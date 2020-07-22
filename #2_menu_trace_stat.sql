# 2번 문제
WITH
`menu_trace` AS (
	SELECT
		curr_t.usr_no,
        curr_t.menu_nm,
        (
			SELECT menu_nm
            FROM KAKAOBANK.MENU_LOG prev_t
            WHERE curr_t.log_tktm > prev_t.log_tktm
				AND curr_t.usr_no = prev_t.usr_no
			ORDER BY log_tktm DESC LIMIT 1
        ) AS prev_menu_nm
	FROM KAKAOBANK.MENU_LOG curr_t
    WHERE curr_t.menu_nm NOT IN ('login', 'logout')
	HAVING prev_menu_nm IS NOT NULL
		AND prev_menu_nm NOT IN ('login', 'logout')
)
SELECT
	menu_nm AS `메뉴명`,
    prev_menu_nm AS `이전 메뉴명`,
    COUNT(*) AS `접근 건수`,
    TRUNCATE((COUNT(*)/(SUM(COUNT(*)) OVER (PARTITION BY menu_nm))) * 100, 2) AS `비율(%)`
FROM `menu_trace`
GROUP BY menu_nm, prev_menu_nm
ORDER BY `메뉴명` ASC, `접근 건수` DESC, `이전 메뉴명` ASC 
;