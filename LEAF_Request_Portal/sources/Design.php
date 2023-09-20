<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class Design
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $dataActionLogger;

    private $template_options = array('homepage','testpage');


    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $this->dataActionLogger = new \Leaf\DataActionLogger($db, $login);
        
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
    }


    public function getAllDesigns(): array
    {
        $strSQL = 'SELECT designID, templateName, designName, designContent FROM template_designs';
        return $this->db->prepared_query($strSQL, null) ?? [];
    }

    public function getHistory(?string $filterById): array
    {
        return $this->dataActionLogger->getHistory($filterById, "templateName", \Leaf\LoggableTypes::TEMPLATE_DESIGN);
    }


    public function cleanInput(string $inputJSON, string $templateName): string
    {
        $return_value = '{}';
        switch($templateName) {
            case 'homepage':
                $inputData = json_decode($inputJSON, true);

                $menuItemsIn = $inputData['menu']['menuCards'] ?? [];
                foreach ($menuItemsIn as $i => $item) {
                    $card = array();
                    $card['id'] = \Leaf\XSSHelpers::xscrub($item['id']);
                    $card['order'] = (int) \Leaf\XSSHelpers::xscrub($item['order']);
                    $card['title'] = \Leaf\XSSHelpers::sanitizer($item['title'] ?? '');
                    $card['subtitle'] = \Leaf\XSSHelpers::sanitizer($item['subtitle'] ?? '');
                    $card['titleColor'] = \Leaf\XSSHelpers::xscrub($item['titleColor'] ?? '#000000');
                    $card['subtitleColor'] =  \Leaf\XSSHelpers::xscrub($item['subtitleColor'] ?? '#000000');
                    $card['bgColor'] = \Leaf\XSSHelpers::xscrub($item['bgColor'] ?? '#ffffff');
                    $card['link'] = \Leaf\XSSHelpers::scrubNewLinesFromURL(\Leaf\XSSHelpers::xscrub($item['link'] ?? ''));
                    $card['icon'] = \Leaf\XSSHelpers::scrubFilename($item['icon'] ?? '');
                    $card['enabled'] = (int) $item['enabled'] === 1 ? 1 : 0;
                    $menuCards[] = $card;
                }
        
                $headerIn = $inputData['header'] ?? array();
                $header['title'] = \Leaf\XSSHelpers::xscrub($headerIn['title'] ?? '');
                $header['titleColor'] = \Leaf\XSSHelpers::xscrub($headerIn['titleColor'] ?? '#000000');
                $header['headerType'] = (int) ($headerIn['headerType'] ?? 1);
                $header['imageFile'] = \Leaf\XSSHelpers::scrubFilename($headerIn['imageFile'] ?? '');
                $header['imageW'] = (int) ($headerIn['imageW'] ?? 0);
                $header['enabled'] = (int) ($headerIn['enabled'] ?? 0);
        
                $home_design_data['menu']['menuCards'] = $menuCards ?? [];
                $home_design_data['menu']['direction'] = $inputData['menu']['direction'] === 'v' ? 'v' : 'h';
                $home_design_data['header'] = $header;
                $home_design_data['searchHeaders'] =  \Leaf\XSSHelpers::scrubObjectOrArray($inputData['searchHeaders']);

                $return_value = json_encode($home_design_data);
                break;
            case 'testpage':
                $test = array('test' => 'data');
                $return_value = json_encode($test);
                break;
            default:
                break;
        }
        return $return_value;
    }

    public function newDesign(string $templateName = '', string $designName = '', string $inputJSON = '{}'): array
    {
        if (!$this->login->checkGroup(1)) {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "Admin access required";

        } elseif (in_array($templateName, $this->template_options)) {

            $designContent = $inputJSON === '{}' ? $inputJSON : $this->cleanInput($inputJSON, $templateName);

            $strSQL = "INSERT INTO template_designs (templateName, designName, designContent)
                VALUES (:templateName, :designName, :designContent)";
            $vars = array(
                ':templateName' => $templateName,
                ':designName' => $designName,
                ':designContent' => $designContent,
            );

            $return_value = $this->db->pdo_insert_query($strSQL, $vars);
            $newDesignID = $this->db->getLastInsertID();
            $return_value['data'] = (int)$newDesignID;

            $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::TEMPLATE_DESIGN, [
                new \Leaf\LogItem("template_designs", "designID", $newDesignID),
                new \Leaf\LogItem("template_designs", "templateName", $templateName)
            ]);

        } else {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "specified page cannot have design settings";
        }

        return $return_value;
    }

    public function updateDesignContent(string $inputJSON = '{}', int $designID = 0, string $templateName ): array
    {
        if (!$this->login->checkGroup(1)) {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "Admin access required";

        } elseif (in_array($templateName, $this->template_options)) {

            $designContent = $this->cleanInput($inputJSON, $templateName);

            $strSQL = 'UPDATE template_designs SET designContent=:designContent WHERE designID=:designID';

            $vars = array(
                ':designID' => $designID,
                ':designContent' => $designContent
            );

            $return_value = $this->db->pdo_update_query($strSQL, $vars);
            $return_value['data'] = $designContent;

            $this->dataActionLogger->logAction(\Leaf\DataActions::MODIFY, \Leaf\LoggableTypes::TEMPLATE_DESIGN, [
                new \Leaf\LogItem("template_designs", "designID", $designID),
                new \Leaf\LogItem("template_designs", "templateName", $templateName),
                new \Leaf\LogItem("template_designs", "designContent", $designContent)
            ]);

        } else {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "specified page cannot have design settings";
        }

        return $return_value;
    }

    public function updateDesignName(int $designID, string $designName): array
    {
        if (!$this->login->checkGroup(1)) {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "Admin access required";

        } else {
            $strSQL = 'UPDATE template_designs SET designName=:designName WHERE designID=:designID';
            $vars = array(
                ':designID' => $designID,
                ':designName' => $designName
            );
            $return_value = $this->db->pdo_update_query($strSQL, $vars);
            $return_value['data'] = $designID;
            return $return_value;
        }
    }

    public function deleteDesign(int $designID, string $templateName): array
    {
        if (!$this->login->checkGroup(1)) {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "Admin access required";

        } else {
            $strSQL = 'DELETE FROM template_designs WHERE designID=:designID';
            $vars = array(
                ':designID' => $designID,
            );

            $return_value = $this->db->pdo_delete_query($strSQL, $vars);
            $return_value['data'] = $designID;

            $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE, \Leaf\LoggableTypes::TEMPLATE_DESIGN, [
                new \Leaf\LogItem("template_designs", "designID", $designID),
                new \Leaf\LogItem("template_designs", "templateName", $templateName)
            ]);
        }
        return $return_value;
    }

    public function publishTemplate(int $designID = 0, int $currentID = 0, string $templateName = ''): array
    {
        if (!$this->login->checkGroup(1)) {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "Admin access required";

        } elseif (in_array($templateName, $this->template_options)) {
            $settings_key = $templateName.'_enabled';

            $strSQL = 'INSERT INTO settings (setting, `data`)
                VALUES (:settings_key, :designID)
                ON DUPLICATE KEY UPDATE `data`=:designID';
            $vars = array(
                ':settings_key' => $settings_key,
                ':designID' => $designID
            );

            $return_value = $this->db->pdo_insert_query($strSQL, $vars);
            $return_value['data'] = array(
                'setting' => $settings_key,
                'published' => $designID
            );

            if($designID > 0) {
                if($currentID > 0) {
                    $this->dataActionLogger->logAction(\Leaf\DataActions::MODIFY, \Leaf\LoggableTypes::UNPUBLISH, [
                        new \Leaf\LogItem("template_designs", "designID", $currentID),
                        new \Leaf\LogItem("template_designs", "templateName", $templateName)
                    ]);
                }
                $this->dataActionLogger->logAction(\Leaf\DataActions::MODIFY, \Leaf\LoggableTypes::PUBLISH, [
                    new \Leaf\LogItem("template_designs", "designID", $designID),
                    new \Leaf\LogItem("template_designs", "templateName", $templateName)
                ]);

            } else {
                $this->dataActionLogger->logAction(\Leaf\DataActions::MODIFY, \Leaf\LoggableTypes::UNPUBLISH, [
                    new \Leaf\LogItem("template_designs", "designID", $currentID),
                    new \Leaf\LogItem("template_designs", "templateName", $templateName)
                ]);
            }
            
        } else {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "specified page cannot have design settings";
        }
        return $return_value;
    }

}