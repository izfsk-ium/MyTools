#include <readline/history.h>
#include <readline/readline.h>

#define PROGRAM_NAME "transhell"
#define PROGRAM_VERSION "0.1"

#define USER_AGENT                                                             \
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like " \
  "Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"

typedef struct {
  char *name;         /* command name. */
  rl_icpfunc_t *func; /* Function to call to do the job. */
} Command;

typedef struct {
  const char *identify_file_location;
  int exists;
} IdentityFile;