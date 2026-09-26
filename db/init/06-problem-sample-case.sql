-- Sample cases shown in the statement and the IDE (the API maps it as DbProblemSample).
USE jol;

CREATE TABLE IF NOT EXISTS `problem_sample_case` (
  `problem_id` int(11) NOT NULL,
  `num` int(11) NOT NULL,
  `input` text DEFAULT NULL,
  `output` text DEFAULT NULL,
  PRIMARY KEY (`problem_id`, `num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
