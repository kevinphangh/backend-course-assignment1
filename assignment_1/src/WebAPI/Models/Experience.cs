namespace WebAPI.Models
{
    // Data model for an experience/service
    public class Experience
    {
        public required string Name { get; set; }
        public required string Description { get; set; }
        public decimal? Price { get; set; }  // Nullable decimal to match database DECIMAL(10,2)
    }
}