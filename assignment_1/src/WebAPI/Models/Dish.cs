namespace WebAPI.Models
{
    /// <summary>
    /// Menu item DTO for API responses
    /// </summary>
    public class Dish
    {
        public string Name { get; set; }

        /// <summary>
        /// Price in DKK - nullable per assignment requirements
        /// </summary>
        public int? Price { get; set; }
    }
}