recalculaHoras();
$(document).on('nested:fieldAdded', function(event) {
    formChanged(event.field.closest("form"));
    createSlider(event.field.find('.slider'));
});
$(document).on('nested:fieldRemoved', function(event) {
    formChanged(event.field.closest("form"));
});

function createTimePicker(obj) {
  $(obj).timepicker({
    showPeriodLabels: false
  });
}

$('.timepicker').timepicker({
    showPeriodLabels: false
});

//$('.timepicker').on('shown', function() {
  //$(this).timepicker({
   // showPeriodLabels: false
 // });
//});

$('#boards').on('hidden', function() {
    ajustaAltura();
});

$('#boards').on('shown', function() {
    ajustaAltura();
});

initializeSliders();
updateHorasAtividades(sumSliders(), pega_horas_dia().totalHorasDia, $("#horas_atividades"));
ajustaAltura();

function updateTags(obj) {
    var id_nome_string = obj.id.toString().replace("_card", "");
    box = $(obj).prev();
    $.ajax({
        url: "/dias/cartao_tags",
        data: {cartao_id: id_nome_string},
        success: function(result) {
            box.val(result);
        }
    });
}

function split(val) {
    return val.split(/,\s*/);
}
function extractLast(term) {
    return split(term).pop();
}

function tag_autocomplete_apply() {
    $(".tag_autocomplete")
// don't navigate away from the field on tab when selecting an item
            .bind("keydown", function(event) {
        if (event.keyCode === $.ui.keyCode.TAB &&
                $(this).data("ui-autocomplete").menu.active) {
            event.preventDefault();
        }
    })
            .autocomplete({
        minLength: 0,
        source: function(request, response) {
// delegate back to autocomplete, but extract the last term
            response($.ui.autocomplete.filter(
                    availableTags, extractLast(request.term)));
        },
        focus: function() {
// prevent value inserted on focus
            return false;
        },
        select: function(event, ui) {
            var terms = split(this.value);
// remove the current input
            terms.pop();
// add the selected item
            terms.push(ui.item.value);
// add placeholder to get the comma-and-space at the end
            terms.push("");
            this.value = terms.join(", ");
            return false;
        }
    });
}

function recalculaHoras() {
    // updateAllSliders();
    horas = pega_horas_dia();
    $("#horas_do_dia").text(getTime(horas.totalHorasDia));
    $("#dia_intervalo").text(getTime(horas.totalIntervalo));
}

$(window).on('resize', function() {
    ajustaAltura();
});

window.onbeforeunload = function(e) {
    return checkForm();
};
