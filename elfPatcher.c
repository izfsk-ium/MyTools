#include <assert.h>
#include <elf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/stat.h>

#define ORIGINAL_ELF argv[1]
#define APPEND_TARGET argv[2]
#define CUSTOM_SECTION_NAME argv[3]

#define BUFFSIZE 8192

typedef struct ELF_File_Struct {
  Elf64_Ehdr header;                    // The ELF File header
  Elf64_Shdr string_table_section_info; // The section-info which store shstrtab
  Elf64_Shdr *section_table;            // All section tables array

  unsigned char *shstrtab_buff; // The content of shstrtab
} ELF_File_Struct;

ELF_File_Struct original_elf_file, result_elf_file;

FILE *fp_original_elf, *fp_target_append, *fp_output_elf;
size_t original_elf_size, append_target_size;

void init_files(char *elf_file, char *target_file) {
  /* Make sure all files are opened */
  struct stat file_status;
  fp_original_elf = fopen(elf_file, "rb");
  assert(fp_original_elf != NULL);
  fp_target_append = fopen(target_file, "rb");
  assert(fp_target_append != NULL);
  fp_output_elf = fopen("p.out", "wb");
  assert(fp_output_elf != NULL);
  stat(elf_file, &file_status);
  original_elf_size = file_status.st_size;
  stat(target_file, &file_status);
  append_target_size = file_status.st_size;
  assert(original_elf_size != 0 && append_target_size != 0);
}

void print_original_elf_info(ELF_File_Struct *target) {
  printf("ELF file:\n");
  printf("\t Section count %d.\n", target->header.e_shnum);
  printf("\t Section Table starts at %lu.\n", target->header.e_shoff);
  printf("\t .shstrtab starts at %lu.\n",
         target->string_table_section_info.sh_offset);
}

void read_original_elf() {
  /* read  original ELF file header to both struct */
  fread(&original_elf_file.header, sizeof(Elf64_Ehdr), 1, fp_original_elf);
  assert(original_elf_file.header.e_ident[0] == 0x7f &&
         original_elf_file.header.e_ident[1] == 'E' &&
         original_elf_file.header.e_ident[2] == 'L' &&
         original_elf_file.header.e_ident[3] == 'F');

  /* read section table*/
  size_t section_table_entry_size = original_elf_file.header.e_shnum;
  original_elf_file.section_table =
      (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr) * section_table_entry_size);
  assert(original_elf_file.section_table != NULL);
  fseek(fp_original_elf, original_elf_file.header.e_shoff, 0);
  fread(original_elf_file.section_table, sizeof(Elf64_Shdr),
        section_table_entry_size, fp_original_elf);
  assert(original_elf_file.section_table[0].sh_type == 0 &&
         original_elf_file.section_table[0].sh_offset == 0);

  /* read shstrtab info */
  memcpy(&original_elf_file.string_table_section_info,
         &original_elf_file.section_table[original_elf_file.header.e_shstrndx],
         sizeof(Elf64_Shdr));
  assert(original_elf_file.string_table_section_info.sh_type == SHT_STRTAB);

  /* read the shstrtab content to buff */
  original_elf_file.shstrtab_buff = (unsigned char *)malloc(
      original_elf_file.string_table_section_info.sh_size);
  assert(original_elf_file.shstrtab_buff != NULL);
  fseek(fp_original_elf, original_elf_file.string_table_section_info.sh_offset,
        0);
  assert(fread(original_elf_file.shstrtab_buff,
               original_elf_file.string_table_section_info.sh_size, 1,
               fp_original_elf) != 0);
}

void create_new_section(size_t sh_name_index, size_t sh_size, uint64_t offset) {
  /* Alloc memory for new section-info */
  static Elf64_Shdr *new_section_info;
  new_section_info = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr));
  assert(new_section_info != NULL);

  /* Set section info content */
  new_section_info->sh_name = sh_name_index;
  new_section_info->sh_type = SHT_PROGBITS;
  new_section_info->sh_flags = SHF_WRITE;
  new_section_info->sh_addr = 0x0; // This section is not executable
  new_section_info->sh_size = sh_size;
  new_section_info->sh_info = SHN_UNDEF;
  new_section_info->sh_link = SHN_UNDEF;
  new_section_info->sh_entsize = 0;
  new_section_info->sh_addralign = 0;
  new_section_info->sh_offset = offset;

  /* Append it to section-table */ // FIXME
  result_elf_file.section_table = realloc(
      &result_elf_file.section_table, (original_elf_file.header.e_shnum + 1) *
                                          original_elf_file.header.e_shentsize);
  assert(result_elf_file.section_table != NULL);
  memcpy(&result_elf_file.section_table[original_elf_file.header.e_shnum],
         new_section_info, sizeof(Elf64_Shdr));
  assert(
      result_elf_file.section_table[original_elf_file.header.e_shnum].sh_name ==
          sh_name_index &&
      original_elf_file.section_table[0].sh_name == 0);
  free(new_section_info);

  /* Update ELF-header section sum */
  result_elf_file.header.e_shnum += 1;
}

void paint_shstrtab_section_content(const unsigned char *buff, size_t size) {
  /* print shstrtab content. NULL print as '*' */
  printf("\n--> shstrtab Content:\n");
  for (int i = 0; i < size; i++) {
    printf("%c", buff[i] == '\0' ? '*' : buff[i]);
  }
  putchar('\n');
}

size_t patch_shstrtab_section(const char *new_section_name) {
  /* Add custom section name to section string table, return the index of new
   * section name in the modified table */
  size_t new_size = original_elf_file.string_table_section_info.sh_size +
                    strlen(new_section_name) + 1;
  result_elf_file.shstrtab_buff =
      realloc(result_elf_file.shstrtab_buff, new_size);
  assert(result_elf_file.shstrtab_buff != NULL);
  unsigned char *end = result_elf_file.shstrtab_buff +
                       original_elf_file.string_table_section_info.sh_size;
  strncat(end, new_section_name, strlen(new_section_name) + 1);
  result_elf_file.shstrtab_buff[new_size - 1] = '\0';

  /* Copy and update shstrtab section info */
  assert(result_elf_file.string_table_section_info.sh_type == SHT_STRTAB);
  result_elf_file.string_table_section_info.sh_size +=
      strlen(new_section_name) + 1;

  /* Return the new section index */
  return result_elf_file.string_table_section_info.sh_size + 1;
}

uint64_t calculate_new_section_offset(const char *custom_section_name) {
  /* Calculate new section offset, the new section is appended to original elf
   * file */
  return original_elf_size + sizeof(Elf64_Shdr) + strlen(custom_section_name) +
         1;
}

void fix_s_offset_after_section_table() {
  /* Fix sections after section table. All sections after it should have their
   * offset += sizeof(Elf64_Shdr) */
  for (int i = 0; i < result_elf_file.header.e_shnum; i++) {
    if (result_elf_file.section_table[i].sh_offset <=
        result_elf_file.section_table->sh_offset) {
      continue;
    }
    result_elf_file.section_table[i].sh_offset += sizeof(Elf64_Shdr);
  }
}

void fix_s_offset_after_shstrtab_table(const char *custom_name) {
  /* Fix section offset after shstrtab. All add strlen(custom_section_name) + 1
   */
  for (int i = result_elf_file.header.e_shstrndx + 1;
       i <= result_elf_file.header.e_shnum; i++) {
    result_elf_file.section_table[i].sh_offset += strlen(custom_name) + 1;
  }
}

void save_elf_file() {
  unsigned char *buff = (unsigned char *)malloc(BUFFSIZE);
  size_t buff_size = BUFFSIZE;

  /* Save ELF Header first */
  assert(fp_output_elf != NULL);
  fwrite(&result_elf_file.header, sizeof(Elf64_Ehdr), 1, fp_output_elf);

  /* Copy sections before modified section table */
  for (int i = 0; i < result_elf_file.header.e_shnum; i++) {
    Elf64_Shdr target = result_elf_file.section_table[i];
    Elf64_Shdr original = original_elf_file.section_table[i];
    if (target.sh_offset <= result_elf_file.header.e_shoff) {
      printf("Store section %d at %lu size %lu, original %lu size %lu.\n", i,
             target.sh_offset, target.sh_size, original.sh_offset,
             original.sh_size);
      memset(buff, '\0', buff_size);
      fseek(fp_target_append, target.sh_offset, 0);
      if (target.sh_size > buff_size) {
        buff = realloc(buff, buff_size * 2);
        assert(buff != NULL);
        buff_size *= 2;
      }
      fread(buff, target.sh_size, 1, fp_target_append);
      fwrite(buff, target.sh_size, 1, fp_output_elf);
    }
  }
}

int main(int argc, char **argv) {
  if (argc != 4) {
    printf("Error: bad usage.\n");
    printf("Usage: patcher original_elf_file file_to_append "
           "custom_section_name\n");
    exit(1);
  }
  init_files(ORIGINAL_ELF, APPEND_TARGET);
  read_original_elf();
  print_original_elf_info(&original_elf_file);

  /* Copy everything to result elf file */
  memcpy(&result_elf_file, &original_elf_file, sizeof(ELF_File_Struct));

  /* Patch shstrtab section content and shstrtab section info */
  paint_shstrtab_section_content(
      original_elf_file.shstrtab_buff,
      original_elf_file.string_table_section_info.sh_size);
  size_t new_section_name_index = patch_shstrtab_section(CUSTOM_SECTION_NAME);
  paint_shstrtab_section_content(
      result_elf_file.shstrtab_buff,
      result_elf_file.string_table_section_info.sh_size);

  /* Create New section */
  uint64_t new_section_offset =
      calculate_new_section_offset(CUSTOM_SECTION_NAME);
  create_new_section(new_section_name_index, append_target_size,
                     new_section_offset);

  /* Fix offsets */
  fix_s_offset_after_section_table();
  fix_s_offset_after_shstrtab_table(CUSTOM_SECTION_NAME);

  /* Now store new file */
  print_original_elf_info(&result_elf_file);
  save_elf_file();
}
