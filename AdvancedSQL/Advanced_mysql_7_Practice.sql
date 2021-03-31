/** 
1. 테이블별 관계 정의 1:1 관계
**/
CREATE TABLE `Club` (
	id int unsigned not null auto_increment primary key, 
	name varchar(31) not null,
    createdate timestamp not null default current_timestamp,
    leader int unsigned
    );
desc Club;
-- Alter Table 로 테이블 상세 내역 확인 가능 
-- Index 설정되어있으면 Join  
-- Index sorted 색인 키 > Join 시 두 테이블에 정의된 Index면 성능 향상



CREATE TABLE `Enroll` (
	id int unsigned not null auto_increment primary key, 
    subject smallint unsigned not null,
    student int unsigned not null
);


CREATE TABLE Grade (
	id int unsigned not null auto_increment primary key,
    midterm tinyint unsigned not null default 0,				--  tinyint + unsigned 256, 수식 작성시 null있으면 에러나므로 default 0
	finalterm tinyint unsigned not null default 0,
	enroll int unsigned,
    constraint foreign key fk_enroll(enroll) references Enroll(id)
);

desc Grade;
Show create Table Grade;

/** 
CREATE TABLE `grade` (
   `id` int unsigned NOT NULL AUTO_INCREMENT,
   `midterm` tinyint unsigned NOT NULL DEFAULT '0',
   `finalterm` tinyint unsigned NOT NULL DEFAULT '0',
   `enroll` int unsigned DEFAULT NULL,
   PRIMARY KEY (`id`),
   KEY `fk_enroll` (`enroll`),
   CONSTRAINT `grade_ibfk_1` FOREIGN KEY (`enroll`) REFERENCES `enroll` (`id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
 **/
 
 insert into Grade(enroll, midterm, finalterm )
 select id, 
		Ceil((0.5 + rand()/2) * 100),
        mod(id,50)+50
from Enroll;