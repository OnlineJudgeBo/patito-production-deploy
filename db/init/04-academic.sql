-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 02, 2026 at 02:09 AM
-- Server version: 11.3.2-MariaDB-1:11.3.2+maria~ubu2204
-- PHP Version: 8.1.2-1ubuntu2.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `academic`
--
CREATE DATABASE IF NOT EXISTS `academic` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `academic`;

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `course_id` bigint(20) NOT NULL,
  `course_key` varchar(64) NOT NULL,
  `invite_code` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_by_user_id` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `course`
--


-- --------------------------------------------------------

--
-- Table structure for table `course_assignment`
--

CREATE TABLE `course_assignment` (
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `opens_at` datetime NOT NULL,
  `due_at` datetime NOT NULL,
  `late_due_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by_user_id` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `course_assignment`
--


-- --------------------------------------------------------

--
-- Table structure for table `course_assignment_problem`
--

CREATE TABLE `course_assignment_problem` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `problem_id` int(11) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 100,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `course_assignment_problem`
--


-- --------------------------------------------------------

--
-- Table structure for table `course_submission_context`
--

CREATE TABLE `course_submission_context` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `solution_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `course_submission_context`
--


-- --------------------------------------------------------

--
-- Table structure for table `course_user`
--

CREATE TABLE `course_user` (
  `course_id` bigint(20) NOT NULL,
  `user_id` varchar(48) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `role` varchar(16) NOT NULL DEFAULT 'estudiante'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `course_user`
--


-- --------------------------------------------------------

--
-- Table structure for table `learning_path`
--

CREATE TABLE `learning_path` (
  `learning_path_id` bigint(20) NOT NULL,
  `learning_path_key` varchar(64) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `version` int(11) NOT NULL,
  `language_primary` varchar(32) NOT NULL,
  `category` varchar(64) NOT NULL,
  `slug` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `learning_path`
--


-- --------------------------------------------------------

--
-- Table structure for table `learning_path_progress`
--

CREATE TABLE `learning_path_progress` (
  `learning_path_id` bigint(20) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `last_topic_id` varchar(128) DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `learning_path_progress`
--


-- --------------------------------------------------------

--
-- Table structure for table `learning_path_topic`
--

CREATE TABLE `learning_path_topic` (
  `learning_path_id` bigint(20) NOT NULL,
  `topic_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `learning_path_topic`
--


-- --------------------------------------------------------

--
-- Table structure for table `learning_path_topic_progress`
--

CREATE TABLE `learning_path_topic_progress` (
  `learning_path_id` bigint(20) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `topic_id` varchar(128) NOT NULL,
  `completed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `learning_path_topic_progress`
--


-- --------------------------------------------------------

--
-- Table structure for table `problem_tag`
--

CREATE TABLE `problem_tag` (
  `tag_id` bigint(20) NOT NULL,
  `tag_key` varchar(64) NOT NULL,
  `name` varchar(128) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `problem_tag`
--


-- --------------------------------------------------------

--
-- Table structure for table `problem_tag_map`
--

CREATE TABLE `problem_tag_map` (
  `problem_id` bigint(20) NOT NULL,
  `tag_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subtopic`
--

CREATE TABLE `subtopic` (
  `subtopic_id` bigint(20) NOT NULL,
  `topic_id` bigint(20) NOT NULL,
  `subtopic_key` varchar(96) NOT NULL,
  `title` varchar(255) NOT NULL,
  `summary` text DEFAULT NULL,
  `theory` text DEFAULT NULL,
  `learning_objectives` text DEFAULT NULL,
  `difficulty_band` varchar(64) DEFAULT NULL,
  `sort_order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `subtopic`
--


-- --------------------------------------------------------

--
-- Table structure for table `subtopic_problem`
--

CREATE TABLE `subtopic_problem` (
  `subtopic_id` bigint(20) NOT NULL,
  `problem_id` bigint(20) NOT NULL,
  `role_in_topic` varchar(16) NOT NULL DEFAULT 'core',
  `sort_order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subtopic_tag`
--

CREATE TABLE `subtopic_tag` (
  `subtopic_id` bigint(20) NOT NULL,
  `tag_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `subtopic_tag`
--


-- --------------------------------------------------------

--
-- Table structure for table `topic`
--

CREATE TABLE `topic` (
  `topic_id` bigint(20) NOT NULL,
  `topic_key` varchar(96) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) NOT NULL,
  `unlocked_by_default` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `topic`
--


--
-- Indexes for dumped tables
--

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`course_id`),
  ADD UNIQUE KEY `course_key` (`course_key`),
  ADD UNIQUE KEY `uk_course_invite_code` (`invite_code`);

--
-- Indexes for table `course_assignment`
--
ALTER TABLE `course_assignment`
  ADD PRIMARY KEY (`assignment_id`),
  ADD KEY `idx_course_assignment_course` (`course_id`);

--
-- Indexes for table `course_assignment_problem`
--
ALTER TABLE `course_assignment_problem`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_course_assignment_problem` (`assignment_id`,`problem_id`),
  ADD KEY `idx_course_assignment_problem_assignment` (`assignment_id`),
  ADD KEY `idx_course_assignment_problem_problem` (`problem_id`);

--
-- Indexes for table `course_submission_context`
--
ALTER TABLE `course_submission_context`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_course_submission_solution` (`solution_id`),
  ADD KEY `idx_course_submission_course` (`course_id`),
  ADD KEY `idx_course_submission_assignment` (`assignment_id`),
  ADD KEY `idx_course_submission_user` (`user_id`);

--
-- Indexes for table `course_user`
--
ALTER TABLE `course_user`
  ADD PRIMARY KEY (`course_id`,`user_id`),
  ADD KEY `idx_course_user_user` (`user_id`);

--
-- Indexes for table `learning_path`
--
ALTER TABLE `learning_path`
  ADD PRIMARY KEY (`learning_path_id`),
  ADD UNIQUE KEY `learning_path_key` (`learning_path_key`);

--
-- Indexes for table `learning_path_progress`
--
ALTER TABLE `learning_path_progress`
  ADD PRIMARY KEY (`learning_path_id`,`user_id`),
  ADD KEY `idx_learning_path_progress_user` (`user_id`);

--
-- Indexes for table `learning_path_topic`
--
ALTER TABLE `learning_path_topic`
  ADD PRIMARY KEY (`learning_path_id`,`topic_id`),
  ADD KEY `fk_lpt_topic` (`topic_id`);

--
-- Indexes for table `learning_path_topic_progress`
--
ALTER TABLE `learning_path_topic_progress`
  ADD PRIMARY KEY (`learning_path_id`,`user_id`,`topic_id`),
  ADD KEY `idx_learning_path_topic_progress_user` (`user_id`);

--
-- Indexes for table `problem_tag`
--
ALTER TABLE `problem_tag`
  ADD PRIMARY KEY (`tag_id`),
  ADD UNIQUE KEY `tag_key` (`tag_key`);

--
-- Indexes for table `problem_tag_map`
--
ALTER TABLE `problem_tag_map`
  ADD PRIMARY KEY (`problem_id`,`tag_id`),
  ADD KEY `idx_ptm_tag` (`tag_id`);

--
-- Indexes for table `subtopic`
--
ALTER TABLE `subtopic`
  ADD PRIMARY KEY (`subtopic_id`),
  ADD UNIQUE KEY `topic_id` (`topic_id`,`subtopic_key`);

--
-- Indexes for table `subtopic_problem`
--
ALTER TABLE `subtopic_problem`
  ADD PRIMARY KEY (`subtopic_id`,`problem_id`),
  ADD KEY `idx_sp_problem` (`problem_id`);

--
-- Indexes for table `subtopic_tag`
--
ALTER TABLE `subtopic_tag`
  ADD PRIMARY KEY (`subtopic_id`,`tag_id`),
  ADD KEY `fk_st_tag` (`tag_id`);

--
-- Indexes for table `topic`
--
ALTER TABLE `topic`
  ADD PRIMARY KEY (`topic_id`),
  ADD UNIQUE KEY `topic_key` (`topic_key`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `course`
--
ALTER TABLE `course`
  MODIFY `course_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_assignment`
--
ALTER TABLE `course_assignment`
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_assignment_problem`
--
ALTER TABLE `course_assignment_problem`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_submission_context`
--
ALTER TABLE `course_submission_context`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learning_path`
--
ALTER TABLE `learning_path`
  MODIFY `learning_path_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `problem_tag`
--
ALTER TABLE `problem_tag`
  MODIFY `tag_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subtopic`
--
ALTER TABLE `subtopic`
  MODIFY `subtopic_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `topic`
--
ALTER TABLE `topic`
  MODIFY `topic_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course_user`
--
ALTER TABLE `course_user`
  ADD CONSTRAINT `fk_course_user_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `learning_path_progress`
--
ALTER TABLE `learning_path_progress`
  ADD CONSTRAINT `fk_learning_path_progress_path` FOREIGN KEY (`learning_path_id`) REFERENCES `learning_path` (`learning_path_id`) ON DELETE CASCADE;

--
-- Constraints for table `learning_path_topic`
--
ALTER TABLE `learning_path_topic`
  ADD CONSTRAINT `fk_lpt_path` FOREIGN KEY (`learning_path_id`) REFERENCES `learning_path` (`learning_path_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_lpt_topic` FOREIGN KEY (`topic_id`) REFERENCES `topic` (`topic_id`) ON DELETE CASCADE;

--
-- Constraints for table `learning_path_topic_progress`
--
ALTER TABLE `learning_path_topic_progress`
  ADD CONSTRAINT `fk_learning_path_topic_progress_path` FOREIGN KEY (`learning_path_id`) REFERENCES `learning_path` (`learning_path_id`) ON DELETE CASCADE;

--
-- Constraints for table `problem_tag_map`
--
ALTER TABLE `problem_tag_map`
  ADD CONSTRAINT `fk_ptm_tag` FOREIGN KEY (`tag_id`) REFERENCES `problem_tag` (`tag_id`) ON DELETE CASCADE;

--
-- Constraints for table `subtopic`
--
ALTER TABLE `subtopic`
  ADD CONSTRAINT `fk_subtopic_topic` FOREIGN KEY (`topic_id`) REFERENCES `topic` (`topic_id`) ON DELETE CASCADE;

--
-- Constraints for table `subtopic_problem`
--
ALTER TABLE `subtopic_problem`
  ADD CONSTRAINT `fk_sp_subtopic` FOREIGN KEY (`subtopic_id`) REFERENCES `subtopic` (`subtopic_id`) ON DELETE CASCADE;

--
-- Constraints for table `subtopic_tag`
--
ALTER TABLE `subtopic_tag`
  ADD CONSTRAINT `fk_st_subtopic` FOREIGN KEY (`subtopic_id`) REFERENCES `subtopic` (`subtopic_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_st_tag` FOREIGN KEY (`tag_id`) REFERENCES `problem_tag` (`tag_id`) ON DELETE CASCADE;
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
