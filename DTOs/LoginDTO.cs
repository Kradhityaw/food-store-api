using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace SimpleStore.DTOs
{
    public class LoginDTO
    {
        [DefaultValue("customer1@gmail.com")]
        public string Email { get; set; }
        [DefaultValue("hashed_password_abc")]
        public string Password { get; set; }
    }
}
