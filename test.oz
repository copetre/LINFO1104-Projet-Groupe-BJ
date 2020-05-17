functor
import
Browser
define
Browse = Browser.browse
A = {NewDictionary}
{Dictionary.put A 'hey' 5}
{Browse {Dictionary.get A 'hey'}}
end