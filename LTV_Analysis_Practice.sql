## TACADEMY SQL ANALYSIS COURSE
-- LTV : Life Time Value
-- 유저 개인당 총 발생 수익을 측정하여 유저당 한계 마케팅 비용으로 산출 
-- LTV 구하는 방법: 과거 매출 추이 기반 예측
-- 마케터 > CTC: 유저 한명 유입시키는데 드는 비용

# LTV
-- 1) 
-- 1. 매출 추론 대상: 누적 매출액 추이 (유저당 누적매출액 y, 가입일로부터 경과일x1) 
	-- dimension 국가별, 유입경로
-- 2. 과거(다른 기간) 가입 그룹의 매출 추이 (유저당 누적매출액 y, 가입일로부터 경과일x2) 
-- 3. 유사 매출 추이 : 1과 유사한 그래프 찾아 비교 
	-- Python ML 도구 그래프 비교 
-- 4. 유사 매출 추이 기반하의 1의 향후 예측

-- 2) ARPU / Churn rate 