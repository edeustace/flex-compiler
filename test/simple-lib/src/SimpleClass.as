package
{
    import mx.resources.ResourceManager;

    [ResourceBundle("resources")]
    public class SimpleClass
    {

        [Embed(source = "images/searchButton.png")]
        [Bindable]
        public var image:Class;

        [Bindable]
        public var message:String = "simple class message";

        [Bindable]
        public var resourceMessage:String = ResourceManager.getInstance().getString('resources', 'resource.message');

        public static const NAME:String = "SimpleClass";

        public function SimpleClass()
        {
        }
    }
}
