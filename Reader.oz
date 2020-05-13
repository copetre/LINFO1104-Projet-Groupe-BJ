functor
import
    Open
    Browser
    System
export
    textfile:TextFile
    scan:Scan

define
    Browse = Browser.browse
    Show = System.show
    SuperDictionary = {NewDictionary}
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

    proc{ReadAll N M}
    F 
    TweetStringList
    in
        if N < M then
            F={New Open.file init(name:"tweets/part_"#N#".txt" flags:[read])}
            %TODO -> dont do browse, but send string
            {F read(list:{Browse} size:all)}
            TweetStringList = {CharsToWords nil F}
            {MpM SuperDictionary TweetStringList}
            {F close}
            {ReadAll N+1 M}
        else skip
        end
    end
    %thread {ReadAll 1 10} end
    %thread {ReadAll 10 20} end
    %thread {ReadAll 20 30} end
    %thread {ReadAll 30 40} end
    %thread {ReadAll 40 50} end
    %thread {ReadAll 50 60} end
    %thread {ReadAll 60 70} end
    %thread {ReadAll 70 80} end
    %thread {ReadAll 80 90} end
    %thread {ReadAll 90 100} end
    %thread {ReadAll 100 110} end
    %thread {ReadAll 110 120} end
    %thread {ReadAll 120 130} end
    %thread {ReadAll 130 140} end
    %thread {ReadAll 140 150} end
    %thread {ReadAll 150 160} end
    %thread {ReadAll 160 170} end
    %thread {ReadAll 170 180} end
    %thread {ReadAll 180 190} end
    %thread {ReadAll 190 200} end
    %thread {ReadAll 200 209} end

    fun{WordChar C}
        (&a=<C andthen C=<&z)orelse
        (&A=<C andthen C=<&Z)orelse
        (&0=<C andthen C=<&9)
    end

    fun{WordToAtom PW}
        {StringToAtom {Reverse PW}}
    end

    fun{CharsToWords PW Cs}
        case Cs
        of nil andthen PW==nil then
            nil
        [] nil then
            [{WordToAtom PW}]
        [] C|Cr andthen{WordChar C} then
            {CharsToWords {Char.toLower C}|PW Cr}
        [] C|Cr andthen PW==nil then
            {CharsToWords nil Cr}
        [] C|Cr then
            {WordToAtom PW}|{CharsToWords nil Cr}
        end
    end

    Put=Dictionary.put
    CondGet=Dictionary.condGet

    proc{IncWord D W}
       {Put D W {CondGet D W 0}+1}
    end

    proc{CountWords D Ws}
        case Ws
        of W|Wr then
            {IncWord D W}
            {CountWords D Wr}
        [] nil then skip
        end
    end

    fun{WordFreq Cs D}
       D={NewDictionary}in{CountWords D {CharsToWords nil Cs}}
       D
    end


    fun {IndMax L Acc Cnt} %Return l'index du premier mot le plus r�p�t�
        case L
        of H|T then
            if (H > Acc) then
    	        Cnt|{IndMax T H Cnt+1}
            else
    	        {IndMax T Acc Cnt+1}
            end
        [] nil then nil
        end
    end


    proc {Max V Y} %Browse le mot en question
        {Browse{List.nth {Dictionary.keys Y} {List.nth {IndMax V 0 1} {List.length {IndMax V 0 1}}}}}
    end

    X =  "Le mot le plus utilis� est le mot : le est le mot qui suit le mot le est le mot : mot qui est aussi magnifique" 

    proc {MpM D L}
        case L
        of H|T then
            case T
            of X|Y then
    	        {AddDico D H X}
    	        {MpM D T}
            [] nil then {MpM D T}
            end
        [] nil then skip
        end
    end

    proc{AddDico D Str1 Str2} D2 in
        {Put D Str1 {CondGet D Str1 {NewDictionary}}}
        D2 = {CondGet D Str1 0}
        {Put D2 Str2 {CondGet D2 Str2 0}+1}
    end

    %TweetStringList = {CharsToWords nil X}
    
    %{MpM SuperDictionary TweetStringList}
    {Browse {Dictionary.keys SuperDictionary}}

    %Regardons les mots qui suivent le mot "est" :
    %TODO rendre ca dynamique USER INPUT VALUE
    Str = {StringToAtom "le"}
    %Prenons l'item (le second dic) de la cl� "est" dans le dico 1 (Prout) :
    Key={Dictionary.get SuperDictionary Str}
    %Affiche les mots apr�s "est" :
    {Browse {Dictionary.keys Key}}
    %Affiche le mot le plus fr�quent apr�s "est" :
    ItemKey = {Dictionary.items Key}
    {Max ItemKey Key}
end