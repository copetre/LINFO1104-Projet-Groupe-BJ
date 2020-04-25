functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    OS
    Browser

    Reader
define
%%% Easier macros for imported functions
    Browse = Browser.browse
    Show = System.show

%%% Read File
    fun {GetFirstLine IN_NAME}
        {Reader.scan {New Reader.textfile init(name:IN_NAME)} 1}
    end

%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Frequency count"
        lr(
            text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
            button(text:"Change" action:Press)
        )
        text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )
    proc {Press} Inserted in
        Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
        {Text2 set(1:Inserted)} % you can get/set text this way too
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}

    {Text1 tk(insert 'end' {GetFirstLine "tweets/part_1.txt"})}
    {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events

    {Show 'You can print in the terminal...'}
    {Browse '... or use the browser window'}
end
