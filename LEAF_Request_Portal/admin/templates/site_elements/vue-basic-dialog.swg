<!-- template for the modal component -->

<script type="text/x-template" id="modal-template">

    <transition name="modal">

    <div class="modal-mask">
        <div class="modal-wrapper">
            <div class="modal-container">

                <div class="modal-header">
                    <slot name="header">
                        Header
                    </slot>
                </div>

                <div class="modal-body">
                    <slot name="body">
                        Body
                    </slot>
                </div>

                <div class="modal-footer">
                    <slot name="footer">
                        Footer
                        <button class="modal-default-button" @click="$emit('close')">
                        OK
                        </button>
                    </slot>
                </div>
            </div>
        </div>
    </div>

    </transition>

</script>