namespace WebAPI.Models
{
    // Data model for an experience/service
    public class Experience
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public int? Price { get; set; }  // Nullable integer for optional pricing
    }
}