using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SimpleStore.DTOs;
using SimpleStore.Models;

namespace SimpleStore.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController(FoodStoreContext context) : ControllerBase
    {
        private FoodStoreContext _context = context;

        [HttpPost("login")]
        public IActionResult Login(LoginDTO login)
        {
            if (string.IsNullOrEmpty(login.Email) || string.IsNullOrEmpty(login.Password))
            {
                return BadRequest(new { Message = "Email dan password harus diisi!" });
            }

            if (!new EmailAddressAttribute().IsValid(login.Email))
            {
                return BadRequest(new { Message = "Email yang anda masukkan tidak valid!" });
            }

            var findUser = _context.Users
                .FirstOrDefault(f => f.Email == login.Email && f.Password == login.Password);
            if (findUser == null)
            {
                return NotFound(new { Message = "Pengguna tidak ditemukan!" });
            }

            AppConfig.User = findUser;  

            return Ok(new { Message = "Berhasil melakukan autentikasi!", Data = findUser });
        }

        [HttpPost("register")]
        public IActionResult Register(RegisterDTO register)
        {
            if (string.IsNullOrEmpty(register.Username) || string.IsNullOrEmpty(register.Password) ||
                string.IsNullOrEmpty(register.Email) || string.IsNullOrEmpty(register.ConfirmPassword) ||
                string.IsNullOrEmpty(register.FullName) || string.IsNullOrEmpty(register.PhoneNumber))
            {
                return BadRequest(new { Message = "Dimohon untuk mengisi seluruh data!" });
            }

            if (register.Password.Length < 8)
            {
                return BadRequest(new { Message = "Password minimal memiliki panjang 8 karakter!" });
            }

            if (register.Password != register.ConfirmPassword)
            {
                return BadRequest(new { Message = "Konfirmasi password tidak sama dengan password anda!" });
            }

            if (!new EmailAddressAttribute().IsValid(register.Email))
            {
                return BadRequest(new { Message = "Email yang anda masukkan tidak valid!" });
            }

            if (_context.Users.Any(f => f.Username == register.Username))
            {
                return BadRequest(new { Message = "Username telah digunakan!" });
            }

            if (_context.Users.Any(f => f.Email == register.Email))
            {
                return BadRequest(new { Message = "Email telah digunakan!" });
            }

            if (register.PhoneNumber.Length < 10 || register.PhoneNumber.Length > 15)
            {
                return BadRequest(new { Message = "Nomor telepon harus minimal 10-15 karakter angka!" });
            }

            foreach (var c in register.PhoneNumber)
            {
                if (!char.IsDigit(c) && !char.IsControl(c))
                {
                    return BadRequest("Nomor telepon harus berupa angka!");
                }
            }

            User newUser = new User
            {
                Username = register.Username,
                Password = register.Password,
                Email = register.Email,
                FullName = register.FullName,
                PhoneNumber = register.PhoneNumber,
                UserRole = "Customer",
                IsActive = true
            };

            _context.Users.Add(newUser);
            _context.SaveChanges();

            return Ok(new { 
                Message = "Berhasil melakukan registrasi, silahkan login untuk melakukan autentikasi!" ,
                Data = newUser
            });
        }

        [HttpGet("me")]
        public IActionResult Me()
        {
            if (AppConfig.User == null)
            {
                return Unauthorized(new { Message = "Tidak terautentikasi!" });
            }

            var findUser = _context.Users.Where(f => f == AppConfig.User)
                .Select(f => new
                {
                    f.UserId,
                    f.FullName,
                    f.Email,
                    f.Username,
                    f.Address,
                }).FirstOrDefault();

            return Ok(findUser);
        }

        [HttpGet("logout")]
        public IActionResult Logout()
        {
            if (AppConfig.User == null)
            {
                return Unauthorized(new { Message = "Tidak terautentikasi!" });
            }

            AppConfig.User = null;

            return Ok(new { Message = "Berhasil melakukan logout!" });
        }
    }
}
