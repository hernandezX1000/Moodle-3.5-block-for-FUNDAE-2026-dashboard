<?php
defined('MOODLE_INTERNAL') || die();

class block_fundae extends block_base {
    
    public function init() {
        $this->title = get_string('pluginname', 'block_fundae');
    }

    public function get_content() {
        if ($this->content !== null) {
            return $this->content;
        }
        $this->content = new stdClass;
        $this->content->text = '<h3>Dashboard FUNDAE 2026</h3>';
        $this->content->text .= '<p>Bloque FUNDAE instalado correctamente.</p>';
        $this->content->text .= '<p>Cursos bonificables: 129</p>';
        return $this->content;
    }

    public function applicable_formats() {
        return array('all' => true);
    }

    public function instance_allow_multiple() {
        return false;
    }
    
    public function has_config() {
        return false;
    }
}
