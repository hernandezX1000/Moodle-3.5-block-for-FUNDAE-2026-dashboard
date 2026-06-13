<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

defined('MOODLE_INTERNAL') || die();

class block_fundae extends block_base {
    
    public function init() {
        $this->title = get_string('pluginname', 'block_fundae');
    }

    public function get_content() {
        global $DB, $USER, $OUTPUT;

        if ($this->content !== null) {
            return $this->content;
        }

        $this->content = new stdClass;
        $this->content->text = '';
        $this->content->footer = '';

        // Solo mostrar si el usuario tiene rol de Supervisor FUNDAE
        if (!user_has_role_assignment($USER->id, 10)) { // Rol Supervisor = ID 10
            $this->content->text = get_string('no_access', 'block_fundae');
            return $this->content;
        }

        // Obtener cursos FUNDAE del usuario
        $sql = "SELECT f.*, c.fullname, c.id as courseid
                FROM {fundae} f
                JOIN {course} c ON f.courseid = c.id
                WHERE c.fullname LIKE '%2026%'
                ORDER BY f.empresa, f.c_fundae";
        
        $fundae_data = $DB->get_records_sql($sql);

        if (empty($fundae_data)) {
            $this->content->text = get_string('no_courses', 'block_fundae');
            return $this->content;
        }

        // Generar tabla HTML
        $table = new html_table();
        $table->head = array(
            get_string('c_fundae', 'block_fundae'),
            get_string('course', 'block_fundae'),
            get_string('empresa', 'block_fundae'),
            get_string('modalidad', 'block_fundae'),
            get_string('nivel', 'block_fundae'),
            get_string('horas', 'block_fundae'),
            get_string('participants', 'block_fundae')
        );

        $table->attributes = array(
            'class' => 'fundae-table table table-striped table-hover',
            'style' => 'width: 100%;'
        );

        foreach ($fundae_data as $row) {
            $course_link = html_writer::link(
                new moodle_url('/course/view.php', array('id' => $row->courseid)),
                $row->fullname,
                array('target' => '_blank')
            );
            
            $table->data[] = array(
                $row->c_fundae,
                $course_link,
                $row->empresa,
                $row->modalidad,
                $row->nivel,
                $row->horas_totales . 'h',
                count_course_participants($row->courseid)
            );
        }

        $this->content->text = html_writer::table($table);
        return $this->content;
    }

    public function applicable_formats() {
        return array('my-index' => true, 'site-index' => false);
    }

    public function instance_allow_multiple() {
        return false;
    }
}

function count_course_participants($courseid) {
    global $DB;
    $sql = "SELECT COUNT(DISTINCT ue.userid)
            FROM {enrol} e
            JOIN {user_enrolments} ue ON e.id = ue.enrolid
            WHERE e.courseid = ? AND ue.status = 0";
    return $DB->count_records_sql($sql, array($courseid));
}
