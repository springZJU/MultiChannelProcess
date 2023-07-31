classdef KeyPressRobot
    methods (Static)
        function pressCtrlS()
            robot = java.awt.Robot;
            robot.keyPress(java.awt.event.KeyEvent.VK_CONTROL);
            robot.keyPress(java.awt.event.KeyEvent.VK_S);
            robot.keyRelease(java.awt.event.KeyEvent.VK_S);
            robot.keyRelease(java.awt.event.KeyEvent.VK_CONTROL);
        end
    end
end