import Toybox.Application;
import Toybox.WatchUi;
import Toybox.System;
import ConnectIQComponents;
class ShowcaseApp extends Application.AppBase {
    var count = 0;
    var label;
    var progress;
    var ring;
    function initialize() { AppBase.initialize(); }
    function increment() {
        count++;
        label.setProps({:text=>"Count: " + count.toString()});
        progress.setProps({:value=>(count % 11)/10.0});
        ring.setProps({:value=>(count % 11)/10.0});
    }
    function getInitialView() {
        var theme = new ConnectIQComponents.Theme({:accent=>0x92581F});
        var settings = System.getDeviceSettings();
        var w = settings.screenWidth;
        var h = settings.screenHeight;
        var panel = new ConnectIQComponents.Panel({:x=>w/5, :y=>h/4, :width=>w*3/5, :height=>h/2}, theme);
        var width = w*3/5;
        label = new ConnectIQComponents.Badge({:text=>"Count: 0", :width=>width, :height=>h/8}, theme);
        panel.add(label);
        panel.add(new ConnectIQComponents.OutlineButton({:text=>"Add", :x=>8, :y=>h/7, :width=>width-16,
            :height=>h/8, :onPress=>method(:increment), :style=>{:radius=>20}}, theme));
        progress = new ConnectIQComponents.ProgressBar({:x=>8, :y=>h/3, :width=>width-16, :height=>12}, theme);
        panel.add(progress);
        var root = new ConnectIQComponents.Component({}, theme);
        ring = new ConnectIQComponents.ProgressRing({:x=>w/10, :y=>h/10, :width=>w*4/5, :height=>h*4/5}, theme);
        root.add(ring);
        root.add(panel);
        panel.add(new ConnectIQComponents.Divider({:x=>8, :y=>h*29/100, :width=>width-16, :height=>2}, theme));
        var view = new ConnectIQComponents.ComponentView(root, theme);
        return [view, new ConnectIQComponents.ComponentDelegate(view, method(:increment))];
    }
}
