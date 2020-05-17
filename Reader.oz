functor
import
    Open
export
    textfile:TextFile
    scan:Scan

define
    % Fetches the N-th line in a file
    % @pre: - InFile: a TextFile from the file
    %       - N: the desires Nth line
    % @post: Returns the N-the line or 'none' in case it doesn't exist
    fun {Scan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            none
        else
            if N==1 then
                {InFile close}
                Line
            else
                {Scan InFile N-1}
            end
        end
    end

    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end