using Microsoft.AspNetCore.Mvc;
using WebAPI.Models;

namespace WebAPI.Controllers
{
    // API controller handling experience-related requests
    [ApiController]
    [Route("api/[controller]")]  // Route: /api/experiences
    public class ExperiencesController : ControllerBase
    {
        // Hardcoded experiences as per assignment requirements
        private readonly List<Experience> _experiences = new List<Experience>
        {
            new Experience
            {
                Name = "Night at Noah's Hotel Single room",
                Description = "Comfortable single room accommodation at Noah's Hotel",
                Price = 730.50m  // Decimal with precision
            },
            new Experience
            {
                Name = "Night at Noah's Hotel Double room",
                Description = "Spacious double room accommodation at Noah's Hotel",
                Price = 910.99m
            },
            new Experience
            {
                Name = "Vienna Historic Center Walking Tour",
                Description = "Guided walking tour through Vienna's historic center",
                Price = 100.00m
            }
        };

        // GET: /api/experiences - Returns all available experiences
        [HttpGet]
        public ActionResult<IEnumerable<Experience>> GetExperiences()
        {
            return Ok(_experiences);  // Returns 200 OK with JSON array
        }
    }
}