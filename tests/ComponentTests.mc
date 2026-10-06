import Toybox.Test;
import ConnectIQComponents;
(:test)
function testThemeOverrides(logger) {
    var theme = new ConnectIQComponents.Theme({:accent=>0x123456});
    var first = new ConnectIQComponents.Button({:style=>{:accent=>0xABCDEF}}, theme);
    var second = new ConnectIQComponents.Button({}, theme);
    Test.assertEqual(first.style()[:accent], 0xABCDEF);
    Test.assertEqual(second.style()[:accent], 0x123456);
    first.setProps({:text=>"Changed"});
    Test.assertEqual(first.style()[:accent], 0xABCDEF);
    return true;
}
class PressRecorder {
    var count = 0;
    function initialize() {}
    function pressed() { count++; }
}
(:test)
function testNestedHitTesting(logger) {
    var recorder = new PressRecorder();
    var root = new ConnectIQComponents.Panel({:x=>10, :y=>20}, null);
    var button = new ConnectIQComponents.Button({:x=>5, :y=>5, :width=>20, :height=>20,
        :onPress=>recorder.method(:pressed)}, null);
    root.add(button);
    Test.assert(root.press(15, 25, 0, 0));
    Test.assertEqual(recorder.count, 1);
    Test.assert(!root.press(35, 45, 0, 0));
    button.setProps({:disabled=>true});
    Test.assert(!root.press(16, 26, 0, 0));
    button.setProps({:disabled=>false, :visible=>false});
    Test.assert(!root.press(16, 26, 0, 0));
    Test.assertEqual(recorder.count, 1);
    return true;
}
(:test)
function testTopmostReceivesPress(logger) {
    var first = new PressRecorder();
    var second = new PressRecorder();
    var root = new ConnectIQComponents.Component({}, null);
    root.add(new ConnectIQComponents.Button({:onPress=>first.method(:pressed)}, null));
    root.add(new ConnectIQComponents.Button({:onPress=>second.method(:pressed)}, null));
    Test.assert(root.press(2, 2, 0, 0));
    Test.assertEqual(first.count, 0);
    Test.assertEqual(second.count, 1);
    root.setProps({:visible=>false});
    Test.assert(!root.press(2, 2, 0, 0));
    return true;
}
